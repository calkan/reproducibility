
Scripts used for the "On Genomic Repeats and Reproducibility" manuscript
========================================================================

Mapping Scripts
===============

Using BWA:

	map-HG00096-orig-1.sh: Mapping HG00096 (original order)
	map-HG00096-shuf-1.sh: Reshuffling and mapping HG00096 (shuffled order)
	map-HG02107-orig.sh: Mapping HG02107 (original order)
	map-HG02107-shuf.sh: Reshuffling and mapping HG02107 (shuffled order)
	map-exome-1.sh: Mapping exomes in original order

Variant Callers
===============

	GATK-call-HG00096-orig-1.sh: SNV+Indels using GATK. HG00096, original order.
	GATK-call-HG00096-orig-2.sh: SNV+Indels using GATK. HG00096, original order - rerun.
	GATK-call-HG00096-shuf-1.sh: SNV+Indels using GATK. HG00096, shuffled order.
	GATK-call-HG02107-1.sh: SNV+Indels using GATK. HG02107, original order.
	GATK-call-HG02107-2.sh: SNV+Indels using GATK. HG02107, original order - rerun.
	GATK-call-HG02107-shuf.sh: SNV+Indels using GATK. HG02107, shuffled order.
	GATK-call-exome-1.sh: SNV+Indels using GATK. WES datasets, original order.
	GATK-call-exome-2.sh: SNV+Indels using GATK. WES datasets, original order - rerun.	
	Freebayes-call.sh: SNV+Indels using Freebayes.
	Platypus-call.sh: SNV+Indels using Platypus.
	SAMTools-call.sh: SNV+Indels using SAMtools.
	DELLY-call.sh: SV using DELLY.	
	LUMPY-call.sh: SV using LUMPY.
	genomestrip-HG00096.sh: SV using Genome STRiP (HG00096).
	genomestrip-HG02107.sh: SV using Genome STRiP (HG02107).
	vcfAnalysisRuns.sh: Comparison of VCF files.
	Makefile: to run them all

Read Shuffler
=============
	Makefile
	shuffle-fastq.c
