#Arguments (see below for the detailed descriptions): BAMDIR(required) OUTDIR(required) NUMOFTHREADS(required)

LUMPYBIN=/mnt/compgen/inhouse/src/lumpy/lumpy-sv-0.2.11/bin/lumpyexpress
BAMDIR=$1 #path to the directory where bam files exist. This caller will process all the bam files in this directory. Your bam files should end with ".bam" extension.
OUTDIR=$2 #created VCFs will be created in this directory
NUMOFTHREADS=$3 #number of threads allowed for this run

lumpyWoThreshold () {

	local i=$1
	fname=`basename $i`
	$LUMPYBIN -B $BAMDIR/$fname -o $OUTDIR/"$(echo $fname | sed s/".bam"/".vcf"/)"
}

countThreads=0
for i in `ls $BAMDIR/*.bam`; do lumpyWoThreshold "$i" &
	countThreads=$((countThreads+1))
	if [ "$countThreads" -eq "$NUMOFTHREADS" ]; then
	        wait
	        countThreads=0
	fi
done;
wait