export LUMPYBIN=/mnt/compgen/inhouse/src/lumpy/lumpy-sv-0.2.11/bin/lumpyexpress
BAMDIR=/mnt/storage1/projects/shuffle/BAM/recal
OUTDIR=$1 #/home/cfirtina/LUMPY/VCF

$LUMPYBIN -B $BAMDIR/HG02107.orig.recal.bam -o $OUTDIR/HG02107.orig.recal.final.vcf
$LUMPYBIN -B $BAMDIR/HG02107.orig2.recal.bam -o $OUTDIR/HG02107.orig2.recal.final.vcf
$LUMPYBIN -B $BAMDIR/HG00096.orig2.recal.bam -o $OUTDIR/HG00096.orig2.recal.final.
$LUMPYBIN -B $BAMDIR/HG00096.orig.recal.bam -o $OUTDIR/HG00096.orig.recal.final.vcf
