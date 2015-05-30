# whole genome HG00096 original order - run 2

export GATKDIR=/mnt/compgen/inhouse/bin/
export REF=/mnt/compgen/inhouse/share/gatk_bundle/2.8/b37/human_g1k_v37.fasta
export DBSNP=/mnt/compgen/inhouse/share/gatk_bundle/2.8/b37/dbsnp_138.b37.vcf
export OMNI=/mnt/compgen/inhouse/share/gatk_bundle/2.8/b37/1000G_omni2.5.b37.vcf
export HAPMAP=/mnt/compgen/inhouse/share/gatk_bundle/2.8/b37/hapmap_3.3.b37.vcf
export MILLS=/mnt/compgen/inhouse/share/gatk_bundle/2.8/b37/Mills_and_1000G_gold_standard.indels.b37.vcf

MAXMEM=16g
SAMPLE=HG00096
BAMFILE=HG00096.orig2
THREADS=16

FASTQ='SRR062634 SRR062635 SRR062641 SRR077487 SRR081241'

for i in `echo $FASTQ`;
do
        bwa mem -t $THREADS $REF $i\_1.filt.fastq.gz $i\_2.filt.fastq.gz  | samtools view -@ $THREADS -S -b -u - | samtools sort -@ $THREADS -m $MAXMEM -  tmp.$BAMFILE.$i;
done

samtools merge $BAMFILE.bam tmp*.bam 

picard-tools AddOrReplaceReadGroups I= $BAMFILE.bam O= $BAMFILE.rg.bam RGPU= tata RGID= $SAMPLE RGLB= $SAMPLE RGPL= illumina RGSM= $SAMPLE;


picard-tools MarkDuplicates I= $BAMFILE.rg.bam O= $BAMFILE.rmdup.bam M= $BAMFILE.txt;

rm -f $BAMFILE.bam tmp*.bam $BAMFILE.rg.bam

samtools index $BAMFILE.rmdup.bam

java -d64 -Xmx${MAXMEM} -jar $GATKDIR/GenomeAnalysisTK.jar \
 -T RealignerTargetCreator  \
 -R $REF  \
 -I $BAMFILE.rmdup.bam \
 -o $BAMFILE.rmdup.bam.intervals

java -d64 -Xmx${MAXMEM} -jar $GATKDIR/GenomeAnalysisTK.jar \
 -T IndelRealigner -targetIntervals $BAMFILE.rmdup.bam.intervals \
 -R $REF --knownAlleles $DBSNP \
 -I $BAMFILE.rmdup.bam \
 -o $BAMFILE.realigned.bam

#Base quality score recalibration 


java -d64 -Xmx${MAXMEM} -jar $GATKDIR/GenomeAnalysisTK.jar \
 -T BaseRecalibrator \
 -R $REF -knownSites $DBSNP \
 -I $BAMFILE.realigned.bam \
 -nct ${THREADS}  -o $BAMFILE.recal_data.grp


#Apply base quality score recalibration 


java -d64 -Xmx${MAXMEM} -jar $GATKDIR/GenomeAnalysisTK.jar \
 -T PrintReads \
 -R $REF \
 -I $BAMFILE.realigned.bam \
 -BQSR $BAMFILE.recal_data.grp \
 -o $BAMFILE.recal.bam

rm -f $BAMFILE.realigned.bam $BAMFILE.realigned.bam.bai

java -d64 -Xmx${MAXMEM} -jar $GATKDIR/GenomeAnalysisTK.jar \
 -T HaplotypeCaller \
 -R $REF --dbsnp $DBSNP \
 -I $BAMFILE.recal.bam \
 -o $BAMFILE.hc.vcf \
 -U ALLOW_UNSET_BAM_SORT_ORDER \
 -gt_mode DISCOVERY \
 -mbq 20 -stand_emit_conf 20 -G Standard -A AlleleBalance -nct $THREADS --disable_auto_index_creation_and_locking_when_reading_rods

java -d64 -Xmx${MAXMEM} -jar $GATKDIR/GenomeAnalysisTK.jar \
 -T VariantRecalibrator \
 -input  $BAMFILE.hc.vcf \
 -R $REF \
 -resource:hapmap,VCF,known=false,training=true,truth=true,prior=15.0 $HAPMAP \
 -resource:omni,VCF,known=false,training=true,truth=false,prior=12.0 $OMNI \
 -resource:dbsnp,VCF,known=true,training=false,truth=false,prior=8.0 $DBSNP \
 -resource:mills,VCF,known=true,training=true,truth=true,prior=12.0 $MILLS \
 -an QD -an MQRankSum -an ReadPosRankSum -an MQ -an FS -an SOR -an DP \
 --mode SNP\
 -recalFile $BAMFILE.hc.recal \
 -tranchesFile $BAMFILE.hc.tranches \
 -rscriptFile $BAMFILE.hc.R \
 -nt $THREADS --TStranche 100.0 --TStranche 99.9 --TStranche 99.5 --TStranche 99.0 \
 --TStranche 98.0 --TStranche 97.0 --TStranche 96.0 --TStranche 95.0 --TStranche 94.0 \
 --TStranche 93.0 --TStranche 92.0 --TStranche 91.0 --TStranche 90.0 --disable_auto_index_creation_and_locking_when_reading_rods

java -d64 -Xmx${MAXMEM} -jar $GATKDIR/GenomeAnalysisTK.jar \
 -T ApplyRecalibration  \
 -input $BAMFILE.hc.vcf \
 -R $REF \
 --ts_filter_level 99.0 \
 -recalFile $BAMFILE.hc.recal \
 -tranchesFile $BAMFILE.hc.tranches \
 -o $BAMFILE.hc.vqsrfilter.vcf 


java -d64 -Xmx${MAXMEM} -jar $GATKDIR/GenomeAnalysisTK.jar \
 -T VariantFiltration \
 -R $REF \
 -o $BAMFILE.hc.vqsrfilter_refilter.vcf \
 --variant $BAMFILE.hc.vqsrfilter.vcf \
 --clusterWindowSize 10 \
 --clusterSize 3 \
 --filterExpression "QUAL < 30" \
 --filterName "Qualfilter"

grep  "\#\|PASS" $BAMFILE.hc.vqsrfilter_refilter.vcf > $BAMFILE.hc.final.vcf


java -d64 -Xmx${MAXMEM} -jar $GATKDIR/GenomeAnalysisTK.jar \
 -T UnifiedGenotyper -glm BOTH \
 -R $REF --dbsnp $DBSNP \
 -I $BAMFILE.recal.bam \
 -o $BAMFILE.ug.vcf \
 -U ALLOW_UNSET_BAM_SORT_ORDER \
 -gt_mode DISCOVERY \
 -mbq 20 -stand_emit_conf 20 -G Standard -A AlleleBalance -nt $THREADS --disable_auto_index_creation_and_locking_when_reading_rods


java -d64 -Xmx${MAXMEM} -jar $GATKDIR/GenomeAnalysisTK.jar \
 -T VariantRecalibrator \
 -input  $BAMFILE.ug.vcf \
 -R $REF \
 -resource:hapmap,VCF,known=false,training=true,truth=true,prior=15.0 $HAPMAP \
 -resource:omni,VCF,known=false,training=true,truth=false,prior=12.0 $OMNI \
 -resource:dbsnp,VCF,known=true,training=false,truth=false,prior=8.0 $DBSNP \
 -resource:mills,VCF,known=true,training=true,truth=true,prior=12.0 $MILLS \
 -an QD -an MQRankSum -an ReadPosRankSum -an MQ -an FS -an SOR -an DP \
 --mode SNP\
 -recalFile $BAMFILE.ug.recal \
 -tranchesFile $BAMFILE.ug.tranches \
 -rscriptFile $BAMFILE.ug.R \
 -nt $THREADS --TStranche 100.0 --TStranche 99.9 --TStranche 99.5 --TStranche 99.0 \
 --TStranche 98.0 --TStranche 97.0 --TStranche 96.0 --TStranche 95.0 --TStranche 94.0 \
 --TStranche 93.0 --TStranche 92.0 --TStranche 91.0 --TStranche 90.0 --disable_auto_index_creation_and_locking_when_reading_rods

java -d64 -Xmx${MAXMEM} -jar $GATKDIR/GenomeAnalysisTK.jar \
 -T ApplyRecalibration  \
 -input $BAMFILE.ug.vcf \
 -R $REF \
 --ts_filter_level 99.0 \
 -recalFile $BAMFILE.ug.recal \
 -tranchesFile $BAMFILE.ug.tranches \
 -o $BAMFILE.ug.vqsrfilter.vcf 


java -d64 -Xmx${MAXMEM} -jar $GATKDIR/GenomeAnalysisTK.jar \
 -T VariantFiltration \
 -R $REF \
 -o $BAMFILE.ug.vqsrfilter_refilter.vcf \
 --variant $BAMFILE.ug.vqsrfilter.vcf \
 --clusterWindowSize 10 \
 --clusterSize 3 \
 --filterExpression "QUAL < 30" \
 --filterName "Qualfilter"

grep  "\#\|PASS" $BAMFILE.ug.vqsrfilter_refilter.vcf > $BAMFILE.ug.final.vcf

# cleanup                                                                                                                                                                                                           

rm -f $BAMFILE.hc.recal $BAMFILE.hc.recal.idx $BAMFILE.hc.tranches $BAMFILE.hc.tranches.pdf $BAMFILE.hc.R $BAMFILE.recal_data.grp
rm -f $BAMFILE.rmdup.bam.intervals
rm -f $BAMFILE.ug.recal $BAMFILE.ug.recal.idx $BAMFILE.ug.tranches $BAMFILE.ug.tranches.pdf $BAMFILE.ug.R $BAMFILE.recal_data.grp
