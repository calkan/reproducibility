# exome original order - run 1 map

export REF=/mnt/compgen/inhouse/share/gatk_bundle/2.8/b37/human_g1k_v37.fasta

MAXMEM=32g
SAMPLE=$1
BAMFILE=$1.orig
THREADS=32

echo "sample: " $SAMPLE
cd $1;

FASTQ=`ls *_1.filt.fastq.gz | sed s/_1.filt.fastq.gz//`
COUNT=`ls *_1.filt.fastq.gz | sed s/_1.filt.fastq.gz// | wc -l`

for i in `echo $FASTQ`;
do
        bwa mem -M -t $THREADS $REF $i\_1.filt.fastq.gz $i\_2.filt.fastq.gz  | samtools view -@ $THREADS -S -b -u - | samtools sort -@ $THREADS -m $MAXMEM -  tmp.$BAMFILE.$i;
done

if [ "$COUNT" -gt "1" ]; then
    samtools merge $BAMFILE.bam tmp.$BAMFILE.*bam 
else
    mv tmp.$BAMFILE.$i.bam $BAMFILE.bam
fi

picard-tools AddOrReplaceReadGroups I= $BAMFILE.bam O= $BAMFILE.rg.bam RGPU= tata RGID= $SAMPLE RGLB= $SAMPLE RGPL= illumina RGSM= $SAMPLE;

picard-tools MarkDuplicates I= $BAMFILE.rg.bam O= $BAMFILE.rmdup.bam M= $BAMFILE.txt;

samtools index $BAMFILE.rmdup.bam