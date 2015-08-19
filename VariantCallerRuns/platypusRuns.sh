export PLATYPUSLOC=/mnt/compgen/inhouse/src/platypus/Platypus.py
BAMDIR=$1
OUTDIR=$2 #/home/cfirtina/PLATYPUS/VCF
REFFILE=/mnt/compgen/inhouse/share/gatk_bundle/2.8/b37/human_g1k_v37.fasta

for i in `ls $BAMDIR/*bam`; do
	fname=`basename $i`
	python $PLATYPUSLOC callVariants --bamFiles=$BAMDIR/$fname --refFile=$REFFILE --output=$OUTDIR/"$(echo $fname | sed s/".bam"/".vcf.tmp"/)"
	cat $OUTDIR/"$(echo $fname | sed s/".bam"/".vcf.tmp"/)" | grep "#\|PASS" > $OUTDIR/"$(echo $fname | sed s/".bam"/".vcf"/)"
	rm -f $OUTDIR/"$(echo $fname | sed s/".bam"/".vcf.tmp"/)"
done;
