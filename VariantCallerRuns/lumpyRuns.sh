export LUMPYBIN=/mnt/compgen/inhouse/src/lumpy/lumpy-sv-0.2.11/bin/lumpyexpress
BAMDIR=$1
OUTDIR=$2 #/home/cfirtina/LUMPY/VCF

lumpyWoThreshold () {

	local i=$1
	fname=`basename $i`
	$LUMPYBIN -B $BAMDIR/$fname -o $OUTDIR/"$(echo $fname | sed s/".bam"/".vcf"/)"
}

for i in `ls $BAMDIR/*bam`; do lumpyWoThreshold "$i" & done
wait