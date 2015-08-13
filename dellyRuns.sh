export DELLYBIN=/mnt/compgen/inhouse/bin/delly
BAMDIR=/mnt/storage1/projects/shuffle/BAM/recal
REFFILE=/mnt/compgen/inhouse/share/gatk_bundle/2.8/b37/human_g1k_v37.fasta
OUTDIR=$1 #/home/cfirtina/DELLY/VCF

$DELLYBIN -t TRA -o $OUTDIR/HG00096.orig.tra.final.vcf -g $REFFILE $BAMDIR/HG00096.orig.recal.bam
$DELLYBIN -t INV -o $OUTDIR/HG00096.orig.inv.final.vcf -g $REFFILE $BAMDIR/HG00096.orig.recal.bam
$DELLYBIN -t DUP -o $OUTDIR/HG00096.orig.dup.final.vcf -g $REFFILE $BAMDIR/HG00096.orig.recal.bam
$DELLYBIN -t DEL -o $OUTDIR/HG00096.orig.del.final.vcf -g $REFFILE $BAMDIR/HG00096.orig.recal.bam
$DELLYBIN -t TRA -o $OUTDIR/HG00096.orig2.tra.final.vcf -g $REFFILE $BAMDIR/HG00096.orig2.recal.bam
$DELLYBIN -t INV -o $OUTDIR/HG00096.orig2.inv.final.vcf -g $REFFILE $BAMDIR/HG00096.orig2.recal.bam
$DELLYBIN -t DUP -o $OUTDIR/HG00096.orig2.dup.final.vcf -g $REFFILE $BAMDIR/HG00096.orig2.recal.bam
$DELLYBIN -t DEL -o $OUTDIR/HG00096.orig2.del.final.vcf -g $REFFILE $BAMDIR/HG00096.orig2.recal.bam
$DELLYBIN -t TRA -o $OUTDIR/HG02107.orig2.tra.final.vcf -g $REFFILE $BAMDIR/HG02107.orig2.recal.bam
$DELLYBIN -t INV -o $OUTDIR/HG02107.orig2.inv.final.vcf -g $REFFILE $BAMDIR/HG02107.orig2.recal.bam
$DELLYBIN -t DUP -o $OUTDIR/HG02107.orig2.dup.final.vcf -g $REFFILE $BAMDIR/HG02107.orig2.recal.bam
$DELLYBIN -t DEL -o $OUTDIR/HG02107.orig2.del.final.vcf -g $REFFILE $BAMDIR/HG02107.orig2.recal.bam
$DELLYBIN -t TRA -o $OUTDIR/HG02107.orig.tra.final.vcf -g $REFFILE $BAMDIR/HG02107.orig.recal.bam
$DELLYBIN -t INV -o $OUTDIR/HG02107.orig.inv.final.vcf -g $REFFILE $BAMDIR/HG02107.orig.recal.bam
$DELLYBIN -t DUP -o $OUTDIR/HG02107.orig.dup.final.vcf -g $REFFILE $BAMDIR/HG02107.orig.recal.bam
$DELLYBIN -t DEL -o $OUTDIR/HG02107.orig.del.final.vcf -g $REFFILE $BAMDIR/HG02107.orig.recal.bam