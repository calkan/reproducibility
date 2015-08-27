export DELLYBIN=/mnt/compgen/inhouse/bin/delly
BAMDIR=$1
OUTDIR=$2 #/home/cfirtina/DELLY/VCF
REFFILE=/mnt/compgen/inhouse/share/gatk_bundle/2.8/b37/human_g1k_v37.fasta

delyTra () {
	local i=$1
	fname=`basename $i`
	$DELLYBIN -t TRA -o $OUTDIR/"$(echo "$fname" | sed s/".bam"/".tra.vcf.tmp"/)" -g $REFFILE $BAMDIR/$fname
	#delete id column, delete lowpass lines
	cat $OUTDIR/"$(echo "$fname" | sed s/".bam"/".tra.vcf.tmp"/)" | grep "#\|PASS" | cut -f 1,2,4,5,6,7,8,9,10 > $OUTDIR/"$(echo "$fname" | sed s/".bam"/".tra.vcf"/)"
	rm -f $OUTDIR/"$(echo "$fname" | sed s/".bam"/".tra.vcf.tmp"/)"
}

delyInv () {
	local i=$1
	fname=`basename $i`
	$DELLYBIN -t INV -o $OUTDIR/"$(echo "$fname" | sed s/".bam"/".inv.vcf.tmp"/)" -g $REFFILE $BAMDIR/$fname
	#delete id column, delete lowpass lines
	cat $OUTDIR/"$(echo "$fname" | sed s/".bam"/".inv.vcf.tmp"/)" | grep "#\|PASS" | cut -f 1,2,4,5,6,7,8,9,10 > $OUTDIR/"$(echo "$fname" | sed s/".bam"/".inv.vcf"/)"
	rm -f $OUTDIR/"$(echo "$fname" | sed s/".bam"/".inv.vcf.tmp"/)"
}

delyDup () {
	local i=$1
	fname=`basename $i`
	$DELLYBIN -t DUP -o $OUTDIR/"$(echo "$fname" | sed s/".bam"/".dup.vcf.tmp"/)" -g $REFFILE $BAMDIR/$fname
	#delete id column, delete lowpass lines
	cat $OUTDIR/"$(echo "$fname" | sed s/".bam"/".dup.vcf.tmp"/)" | grep "#\|PASS" | cut -f 1,2,4,5,6,7,8,9,10 > $OUTDIR/"$(echo "$fname" | sed s/".bam"/".dup.vcf"/)"
	rm -f $OUTDIR/"$(echo "$fname" | sed s/".bam"/".dup.vcf.tmp"/)"
}

delyDel () {
	local i=$1
	fname=`basename $i`
	$DELLYBIN -t DEL -o $OUTDIR/"$(echo "$fname" | sed s/".bam"/".del.vcf.tmp"/)" -g $REFFILE $BAMDIR/$fname
	#delete id column, delete lowpass lines
	cat $OUTDIR/"$(echo "$fname" | sed s/".bam"/".del.vcf.tmp"/)" | grep "#\|PASS" | cut -f 1,2,4,5,6,7,8,9,10 > $OUTDIR/"$(echo "$fname" | sed s/".bam"/".del.vcf"/)"
	rm -f $OUTDIR/"$(echo "$fname" | sed s/".bam"/".del.vcf.tmp"/)"
}

for i in `ls $BAMDIR/*.bam`; do
	fname=`basename $i`
	delyTra "$i" & delyInv "$i" & delyDup "$i" & delyDel "$i" & done
done;
wait