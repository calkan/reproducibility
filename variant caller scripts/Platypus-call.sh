PLATYPUSLOC=/mnt/compgen/inhouse/src/platypus/Platypus.py
REFFILE=/mnt/compgen/inhouse/share/gatk_bundle/2.8/b37/human_g1k_v37.fasta
BAMDIR=$1
OUTDIR=$2
NUMOFTHREADS=$3

platypusWoThreshold () {

	local i=$1
	fname=`basename $i`
	python $PLATYPUSLOC callVariants --bamFiles=$BAMDIR/$fname --refFile=$REFFILE --output=$OUTDIR/"$(echo $fname | sed s/".bam"/".vcf.tmp"/)"
	#keep only passed lines
	cat $OUTDIR/"$(echo $fname | sed s/".bam"/".vcf.tmp"/)" | grep "#\|PASS" > $OUTDIR/"$(echo $fname | sed s/".bam"/".vcf"/)"
	rm -f $OUTDIR/"$(echo $fname | sed s/".bam"/".vcf.tmp"/)"
}
for i in `ls $BAMDIR/*bam`; do platypusWoThreshold "$i" &
	countThreads=$((countThreads+1))
	if [ "$countThreads" -eq "$NUMOFTHREADS" ]; then
	        wait
	        countThreads=0
	fi
done;
wait