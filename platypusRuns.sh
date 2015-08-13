export PLATYPUSLOC=/mnt/compgen/inhouse/src/platypus/Platypus.py
BAMDIR=/mnt/storage1/projects/shuffle/BAM/recal
REFFILE=/mnt/compgen/inhouse/share/gatk_bundle/2.8/b37/human_g1k_v37.fasta
OUTDIR=$1 #/home/cfirtina/PLATYPUS/VCF

python $PLATYPUSLOC callVariants --bamFiles=$BAMDIR/HG00096.orig.recal.bam --refFile=$REFFILE --output=$OUTDIR/HG00096.orig.recal.final.vcf
python $PLATYPUSLOC callVariants --bamFiles=$BAMDIR/HG00096.orig2.recal.bam --refFile=$REFFILE --output=$OUTDIR/HG00096.orig2.recal.final.vcf
python $PLATYPUSLOC callVariants --bamFiles=$BAMDIR/HG02107.orig.recal.bam --refFile=$REFFILE --output=$OUTDIR/HG02107.orig.recal.final.vcf
python $PLATYPUSLOC callVariants --bamFiles=$BAMDIR/HG02107.orig2.recal.bam --refFile=$REFFILE --output=$OUTDIR/HG02107.orig2.recal.final.vcf
