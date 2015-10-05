# whole genome HG00096 original order - run 1 map

export REF=/mnt/compgen/inhouse/share/gatk_bundle/2.8/b37/human_g1k_v37.fasta

MAXMEM=16g
SAMPLE=HG00096
BAMFILE=HG00096.orig
THREADS=16

FASTQ='SRR062634 SRR062635 SRR062641'

for i in `echo $FASTQ`;
do
        bwa mem -M -t $THREADS $REF $i\_1.filt.fastq.gz $i\_2.filt.fastq.gz  | samtools view -@ $THREADS -S -b -u - | samtools sort -@ $THREADS -m $MAXMEM -  tmp.$BAMFILE.$i;
done

samtools merge $BAMFILE.bam tmp.$BAMFILE.*.bam 

picard-tools AddOrReplaceReadGroups I= $BAMFILE.bam O= $BAMFILE.rg.bam RGPU= tata RGID= $SAMPLE RGLB= $SAMPLE RGPL= illumina RGSM= $SAMPLE;

picard-tools MarkDuplicates I= $BAMFILE.rg.bam O= $BAMFILE.rmdup.bam M= $BAMFILE.txt;

samtools index $BAMFILE.rmdup.bam