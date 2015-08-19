BAMDIR=$1
OUTDIR=$2 #/home/cfirtina/SAMTOOLS/VCF
REFFILE=/mnt/compgen/inhouse/share/gatk_bundle/2.8/b37/human_g1k_v37.fasta

for i in `ls $BAMDIR/*bam`; do
	fname=`basename $i`
	samtools mpileup -ugf $REFFILE $BAMDIR/$fname | bcftools call -vmO z -o $OUTDIR/"$(echo $fname | sed s/".bam"/".vcf.gz"/)"
	gzip -d $OUTDIR/"$(echo $fname | sed s/".bam"/".vcf.gz"/)"
done;