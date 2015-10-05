BAMDIR=$1
OUTDIR=$2
NUMOFTHREADS=$3
QUALTHRESHOLD=$4
REFFILE=/mnt/compgen/inhouse/share/gatk_bundle/2.8/b37/human_g1k_v37.fasta

samWithThreshold () {
	local i=$1
	fname=`basename $i`
	samtools mpileup -ugf $REFFILE $BAMDIR/$fname | bcftools call -vmO z -o $OUTDIR/"$(echo $fname | sed s/".bam"/".vcf.tmp.gz"/)"
	gzip -d $OUTDIR/"$(echo $fname | sed s/".bam"/".vcf.tmp.gz"/)"
	#qual filter
	cat $OUTDIR/"$(echo $fname | sed s/".bam"/".vcf.tmp"/)" | awk -F'\t' '{if($6 >= qual || substr($1,1,1) == "#") print $0;}' qual="$QUALTHRESHOLD" > $OUTDIR/"$(echo $fname | sed s/".bam"/".vcf"/)"
	rm -f $OUTDIR/"$(echo $fname | sed s/".bam"/".vcf.tmp"/)"
}

samWoThreshold () {
	local i=$1
	fname=`basename $i`
	samtools mpileup -ugf $REFFILE $BAMDIR/$fname | bcftools call -vmO z -o $OUTDIR/"$(echo $fname | sed s/".bam"/".vcf.gz"/)"
	gzip -d $OUTDIR/"$(echo $fname | sed s/".bam"/".vcf.gz"/)"
}

countThreads=0
if [ "$#" -gt 3 ]; then
	for i in `ls $BAMDIR/*bam`; do samWithThreshold "$i" &
	countThreads=$((countThreads+1))
	if [ "$countThreads" -eq "$NUMOFTHREADS" ]; then
	        wait
	        countThreads=0
	fi
	done;
else
	for i in `ls $BAMDIR/*bam`; do samWoThreshold "$i" &
	countThreads=$((countThreads+1))
	if [ "$countThreads" -eq "$NUMOFTHREADS" ]; then
	        wait
	        countThreads=0
	fi
	done;
fi
wait