BAMDIR=$1
OUTDIR=$2 #/home/cfirtina/SAMTOOLS/VCF
QUALTHRESHOLD=$3
REFFILE=/mnt/compgen/inhouse/share/gatk_bundle/2.8/b37/human_g1k_v37.fasta

if [ "$#" -gt 2 ]; then
	for i in `ls $BAMDIR/*bam`; do
		fname=`basename $i`
		samtools mpileup -ugf $REFFILE $BAMDIR/$fname | bcftools call -vmO z -o $OUTDIR/"$(echo $fname | sed s/".bam"/".vcf.tmp.gz"/)"
		gzip -d $OUTDIR/"$(echo $fname | sed s/".bam"/".vcf.gz"/)"
		#qual filter
		cat $OUTDIR/"$(echo $fname | sed s/".bam"/".vcf.tmp"/)" | awk -F'\t' '{if($6 >= qual || substr($1,1,1) == "#") print $0;}' qual="$QUALTHRESHOLD" > $OUTDIR/"$(echo $fname | sed s/".bam"/".vcf"/)"
	done;
else
	for i in `ls $BAMDIR/*bam`; do
		fname=`basename $i`
		samtools mpileup -ugf $REFFILE $BAMDIR/$fname | bcftools call -vmO z -o $OUTDIR/"$(echo $fname | sed s/".bam"/".vcf.gz"/)"
		gzip -d $OUTDIR/"$(echo $fname | sed s/".bam"/".vcf.gz"/)"
	done;
fi