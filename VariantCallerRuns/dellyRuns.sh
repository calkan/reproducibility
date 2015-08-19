export DELLYBIN=/mnt/compgen/inhouse/bin/delly
BAMDIR=$1
OUTDIR=$2 #/home/cfirtina/DELLY/VCF
REFFILE=/mnt/compgen/inhouse/share/gatk_bundle/2.8/b37/human_g1k_v37.fasta

for i in `ls $BAMDIR/*.bam`; do
	fname=`basename $i`
	$DELLYBIN -t TRA -o $OUTDIR/"$(echo "$fname" | sed s/".bam"/".tra.vcf"/)" -g $REFFILE $BAMDIR/$fname | cut -f 1,2,4,5,6,7,8,9,10 > 
	$DELLYBIN -t INV -o $OUTDIR/"$(echo "$fname" | sed s/".bam"/".inv.vcf"/)" -g $REFFILE $BAMDIR/$fname | cut -f 1,2,4,5,6,7,8,9,10 > 
	$DELLYBIN -t DUP -o $OUTDIR/"$(echo "$fname" | sed s/".bam"/".dup.vcf"/)" -g $REFFILE $BAMDIR/$fname | cut -f 1,2,4,5,6,7,8,9,10 > 
	$DELLYBIN -t DEL -o $OUTDIR/"$(echo "$fname" | sed s/".bam"/".del.vcf"/)" -g $REFFILE $BAMDIR/$fname | cut -f 1,2,4,5,6,7,8,9,10 > 
	cat $OUTDIR/"$(echo "$fname" | sed s/".bam"/".tra.vcf"/)" | cut -f 1,2,4,5,6,7,8,9,10 > $OUTDIR/"$(echo "$fname" | sed s/".bam"/".tra.noid.vcf"/)"
	cat $OUTDIR/"$(echo "$fname" | sed s/".bam"/".inv.vcf"/)" | cut -f 1,2,4,5,6,7,8,9,10 > $OUTDIR/"$(echo "$fname" | sed s/".bam"/".inv.noid.vcf"/)"
	cat $OUTDIR/"$(echo "$fname" | sed s/".bam"/".dup.vcf"/)" | cut -f 1,2,4,5,6,7,8,9,10 > $OUTDIR/"$(echo "$fname" | sed s/".bam"/".dup.noid.vcf"/)"
	cat $OUTDIR/"$(echo "$fname" | sed s/".bam"/".del.vcf"/)" | cut -f 1,2,4,5,6,7,8,9,10 > $OUTDIR/"$(echo "$fname" | sed s/".bam"/".del.noid.vcf"/)"
	rm -f $OUTDIR/"$(echo "$fname" | sed s/".bam"/".tra.vcf"/)"
	rm -f $OUTDIR/"$(echo "$fname" | sed s/".bam"/".inv.vcf"/)"
	rm -f $OUTDIR/"$(echo "$fname" | sed s/".bam"/".dup.vcf"/)"
	rm -f $OUTDIR/"$(echo "$fname" | sed s/".bam"/".del.vcf"/)"
done;