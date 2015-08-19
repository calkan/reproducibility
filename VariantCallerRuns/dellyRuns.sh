export DELLYBIN=/mnt/compgen/inhouse/bin/delly
BAMDIR=$1
OUTDIR=$2 #/home/cfirtina/DELLY/VCF
REFFILE=/mnt/compgen/inhouse/share/gatk_bundle/2.8/b37/human_g1k_v37.fasta

for i in `ls $BAMDIR/*.bam`; do
	fname=`basename $i`
	$DELLYBIN -t TRA -o $OUTDIR/"$(echo "$fname" | sed s/".bam"/".tra.vcf.tmp"/)" -g $REFFILE $BAMDIR/$fname
	$DELLYBIN -t INV -o $OUTDIR/"$(echo "$fname" | sed s/".bam"/".inv.vcf.tmp"/)" -g $REFFILE $BAMDIR/$fname
	$DELLYBIN -t DUP -o $OUTDIR/"$(echo "$fname" | sed s/".bam"/".dup.vcf.tmp"/)" -g $REFFILE $BAMDIR/$fname
	$DELLYBIN -t DEL -o $OUTDIR/"$(echo "$fname" | sed s/".bam"/".del.vcf.tmp"/)" -g $REFFILE $BAMDIR/$fname
	cat $OUTDIR/"$(echo "$fname" | sed s/".bam"/".tra.vcf.tmp"/)" | cut -f 1,2,4,5,6,7,8,9,10 > $OUTDIR/"$(echo "$fname" | sed s/".bam"/".tra.vcf"/)"
	cat $OUTDIR/"$(echo "$fname" | sed s/".bam"/".inv.vcf.tmp"/)" | cut -f 1,2,4,5,6,7,8,9,10 > $OUTDIR/"$(echo "$fname" | sed s/".bam"/".inv.vcf"/)"
	cat $OUTDIR/"$(echo "$fname" | sed s/".bam"/".dup.vcf.tmp"/)" | cut -f 1,2,4,5,6,7,8,9,10 > $OUTDIR/"$(echo "$fname" | sed s/".bam"/".dup.vcf"/)"
	cat $OUTDIR/"$(echo "$fname" | sed s/".bam"/".del.vcf.tmp"/)" | cut -f 1,2,4,5,6,7,8,9,10 > $OUTDIR/"$(echo "$fname" | sed s/".bam"/".del.vcf"/)"
	rm -f $OUTDIR/"$(echo "$fname" | sed s/".bam"/".tra.vcf.tmp"/)"
	rm -f $OUTDIR/"$(echo "$fname" | sed s/".bam"/".inv.vcf.tmp"/)"
	rm -f $OUTDIR/"$(echo "$fname" | sed s/".bam"/".dup.vcf.tmp"/)"
	rm -f $OUTDIR/"$(echo "$fname" | sed s/".bam"/".del.vcf.tmp"/)"
done;