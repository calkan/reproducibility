LUMPYBIN=/mnt/compgen/inhouse/src/lumpy/lumpy-sv-0.2.11/bin/lumpyexpress
BAMDIR=$1
OUTDIR=$2
NUMOFTHREADS=$3

lumpyWoThreshold () {

	local i=$1
	fname=`basename $i`
	$LUMPYBIN -B $BAMDIR/$fname -o $OUTDIR/"$(echo $fname | sed s/".bam"/".vcf"/)"
}

countThreads=0
for i in `ls $BAMDIR/*bam`; do lumpyWoThreshold "$i" &
	countThreads=$((countThreads+1))
	if [ "$countThreads" -eq "$NUMOFTHREADS" ]; then
	        wait
	        countThreads=0
	fi
done;
wait