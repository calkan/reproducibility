BAMDIR=/mnt/storage1/projects/shuffle/BAM/recal
REFFILE=/mnt/compgen/inhouse/share/gatk_bundle/2.8/b37/human_g1k_v37.fasta
OUTDIR=$1 #/home/cfirtina/FREEBAYES/VCF

freebayes -b $BAMDIR/HG00096.orig.recal.bam -f $REFFILE> $OUTDIR/HG00096.orig.hc.final.vcf
freebayes -b $BAMDIR/HG00096.orig2.recal.bam -f $REFFILE> $OUTDIR/HG00096.orig2.hc.final.vcf
freebayes -b $BAMDIR/HG02107.orig.recal.bam -f $REFFILE> $OUTDIR/HG02107.orig.hc.final.vcf
freebayes -b $BAMDIR/HG02107.orig2.recal.bam -f $REFFILE> $OUTDIR/HG02107.orig2.hc.final.vcf