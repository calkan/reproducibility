#!/bin/bash

#arguments (see below for the detailed expressions of the arguments): runDir bam

# If you adapt this script for your own use, you will need to set these two variables based on your environment.
# SV_DIR is the installation directory for SVToolkit - it must be an exported environment variable.
# SV_TMPDIR is a directory for writing temp files, which may be large if you have a large data set.
export SV_DIR=/mnt/compgen/inhouse/bin/svtoolkit/
export BUNDLE_DIR=/mnt/compgen/inhouse/share/gatk_bundle/genome_strip/1000G_phase3

SV_TMPDIR=./tmpdir

runDir=$1 #(required) directory where the vcfs will be created
bam=$2 #(required) exact path to bam file.
fname=`basename $bam`
sites="$(echo $fname | sed s/".bam"/".discovery.vcf"/)"
genotypes="$(echo $fname | sed s/".bam"/".genotypes.vcf"/)"

# These executables must be on your path.
which java > /dev/null || exit 1
which Rscript > /dev/null || exit 1
which samtools > /dev/null || exit 1

# For SVAltAlign, you must use the version of bwa compatible with Genome STRiP.
export PATH=${SV_DIR}/bwa:${PATH}
export LD_LIBRARY_PATH=${SV_DIR}/bwa:${LD_LIBRARY_PATH}

mx="-Xmx48g"
classpath="${SV_DIR}/lib/SVToolkit.jar:${SV_DIR}/lib/gatk/GenomeAnalysisTK.jar:${SV_DIR}/lib/gatk/Queue.jar"

mkdir -p ${runDir}/logs || exit 1
mkdir -p ${runDir}/metadata || exit 1

# Display version information.
java -cp ${classpath} ${mx} -jar ${SV_DIR}/lib/SVToolkit.jar

# Run preprocessing.
# For large scale use, you should use -reduceInsertSizeDistributions, but this is too slow for the installation test.
# The method employed by -computeGCProfiles requires a GC mask and is currently only supported for human genomes.

java -cp ${classpath} ${mx} \
    org.broadinstitute.gatk.queue.QCommandLine \
    -S ${SV_DIR}/qscript/SVPreprocess.q \
    -S ${SV_DIR}/qscript/SVQScript.q \
    -gatk ${SV_DIR}/lib/gatk/GenomeAnalysisTK.jar \
    --disableJobReport \
    -cp ${classpath} \
    -configFile genstrip_installtest_parameters.txt \
    -tempDir ${SV_TMPDIR} \
    -R $BUNDLE_DIR/human_g1k_hs37d5.fasta \
    -genomeMaskFile $BUNDLE_DIR/human_g1k_hs37d5.svmask.fasta \
    -copyNumberMaskFile $BUNDLE_DIR/human_g1k_hs37d5.gcmask.fasta \
    -genderMapFile HG02107.gender.map \
    -runDirectory ${runDir} \
    -md ${runDir}/metadata \
    -disableGATKTraversal \
    -useMultiStep \
    -reduceInsertSizeDistributions false \
    -computeGCProfiles true \
    -computeReadCounts true \
    -jobLogDir ${runDir}/logs \
    -I ${bam} \
    -run \
    || exit 1

# Run discovery.
java -cp ${classpath} ${mx} \
    org.broadinstitute.gatk.queue.QCommandLine \
    -S ${SV_DIR}/qscript/SVDiscovery.q \
    -S ${SV_DIR}/qscript/SVQScript.q \
    -gatk ${SV_DIR}/lib/gatk/GenomeAnalysisTK.jar \
    --disableJobReport \
    -cp ${classpath} \
    -configFile genstrip_installtest_parameters.txt \
    -tempDir ${SV_TMPDIR} \
    -R $BUNDLE_DIR/human_g1k_hs37d5.fasta \
    -genomeMaskFile $BUNDLE_DIR/human_g1k_hs37d5.svmask.fasta \
    -genderMapFile HG02107.gender.map \
    -runDirectory ${runDir} \
    -md ${runDir}/metadata \
    -disableGATKTraversal \
    -jobLogDir ${runDir}/logs \
    -minimumSize 100 \
    -maximumSize 1000000 \
    -suppressVCFCommandLines \
    -I ${bam} \
    -O $runDir/${sites} \
    -run \
    || exit 1

# (grep -v ^##fileDate= $runDir/${sites} | grep -v ^##source= | grep -v ^##reference= | diff -q - benchmark/${sites}) \
#     || { echo "Error: test results do not match benchmark data"; exit 1; }

# Run genotyping on the discovered sites.
java -cp ${classpath} ${mx} \
    org.broadinstitute.gatk.queue.QCommandLine \
    -S ${SV_DIR}/qscript/SVGenotyper.q \
    -S ${SV_DIR}/qscript/SVQScript.q \
    -gatk ${SV_DIR}/lib/gatk/GenomeAnalysisTK.jar \
    --disableJobReport \
    -cp ${classpath} \
    -configFile genstrip_installtest_parameters.txt \
    -tempDir ${SV_TMPDIR} \
    -R $BUNDLE_DIR/human_g1k_hs37d5.fasta \
    -genomeMaskFile $BUNDLE_DIR/human_g1k_hs37d5.svmask.fasta \
    -genderMapFile HG02107.gender.map \
    -runDirectory ${runDir} \
    -md ${runDir}/metadata \
    -disableGATKTraversal \
    -jobLogDir ${runDir}/logs \
    -I ${bam} \
    -vcf $runDir/${sites} \
    -O $runDir/${genotypes} \
    -run \
    || exit 1

# (grep -v ^##fileDate= ${genotypes} | grep -v ^##source= | grep -v ^##contig= | grep -v ^##reference= | diff -q - benchmark/${genotypes}) \
#     || { echo "Error: test results do not match benchmark data"; exit 1; }
