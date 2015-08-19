export DELLYBIN=/mnt/compgen/inhouse/bin/delly
BAMDIR=$1
OUTDIR=$2 #/home/cfirtina/DELLY/VCF
REFFILE=/mnt/compgen/inhouse/share/gatk_bundle/2.8/b37/human_g1k_v37.fasta

for i in `ls $BAMDIR/*.bam`; do
	fname=`basename $i`
	$DELLYBIN -t TRA -g $REFFILE $BAMDIR/$fname | cut -f 1,2,4,5,6,7,8,9,10 > $OUTDIR/"$(echo "$fname" | sed s/".bam"/".tra.vcf"/)"
	$DELLYBIN -t INV -g $REFFILE $BAMDIR/$fname | cut -f 1,2,4,5,6,7,8,9,10 > $OUTDIR/"$(echo "$fname" | sed s/".bam"/".inv.vcf"/)"
	$DELLYBIN -t DUP -g $REFFILE $BAMDIR/$fname | cut -f 1,2,4,5,6,7,8,9,10 > $OUTDIR/"$(echo "$fname" | sed s/".bam"/".dup.vcf"/)"
	$DELLYBIN -t DEL -g $REFFILE $BAMDIR/$fname | cut -f 1,2,4,5,6,7,8,9,10 > $OUTDIR/"$(echo "$fname" | sed s/".bam"/".del.vcf"/)"
done;