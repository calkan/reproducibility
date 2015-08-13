BAMDIR=/mnt/storage1/projects/shuffle/BAM/recal
REFFILE=/mnt/compgen/inhouse/share/gatk_bundle/2.8/b37/human_g1k_v37.fasta
OUTDIR=$1 #/home/cfirtina/SAMTOOLS/VCF

samtools mpileup -ugf $REFFILE $BAMDIR/HG02107.orig2.recal.bam | bcftools call -vmO z -o $OUTDIR/HG02107.orig2.recal.final.vcf
samtools mpileup -ugf $REFFILE $BAMDIR/HG02107.orig.recal.bam | bcftools call -vmO z -o $OUTDIR/HG02107.orig.recal.final.vcf
samtools mpileup -ugf $REFFILE $BAMDIR/HG00096.orig2.recal.bam | bcftools call -vmO z -o $OUTDIR/HG00096.orig2.recal.final.vcf
samtools mpileup -ugf $REFFILE $BAMDIR/HG00096.orig.recal.bam | bcftools call -vmO z -o $OUTDIR/HG00096.orig.recal.final.vcf