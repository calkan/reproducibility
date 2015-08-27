BAMDIR=$1
OUTDIR=$2 #/home/cfirtina/SAMTOOLS/VCF
QUALTHRESHOLD=$3
REFFILE=/mnt/compgen/inhouse/share/gatk_bundle/2.8/b37/human_g1k_v37.fasta

if [ "$#" -gt 2 ]; then
	for i in `ls $BAMDIR/*bam`; do
		fname=`basename $i`
		java -jar -Xms512m -Xmx8G -jar /mnt/compgen/inhouse/src/gasv/bin/BAMToGASV.jar $i -MAPPING_QUALITY $3
		mv $i_* $OUTDIR/
		mv $i.gasv.in $OUTDIR/
		mv $i.info $OUTDIR/
		java -jar -Xms512m -Xmx16G -jar /mnt/compgen/inhouse/src/gasv/bin/GASV.jar --batch $OUTDIR/$fname.gasv.in
		mv *.clusters $OUTDIR/
	done;
else
	for i in `ls $BAMDIR/*bam`; do
		fname=`basename $i`
		java -jar -Xms512m -Xmx8G -jar /mnt/compgen/inhouse/src/gasv/bin/BAMToGASV.jar $i
		mv $i_* $OUTDIR/
		mv $i.gasv.in $OUTDIR/
		mv $i.info $OUTDIR/
		java -jar -Xms512m -Xmx16G -jar /mnt/compgen/inhouse/src/gasv/bin/GASV.jar --batch $OUTDIR/$fname.gasv.in
		mv *.clusters $OUTDIR/
	done;
fi
wait