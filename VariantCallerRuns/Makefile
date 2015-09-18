BAMDIR = /home/cfirtina/VariantCallerTests/shufVsOrigBams/
REFFILE = /mnt/compgen/inhouse/share/gatk_bundle/2.8/b37/human_g1k_v37.fasta
OUTDIR = /home/cfirtina/VariantCallerTests/ShufVsOrig/
FIRSTVCF = orig
SECONDVCF = shuf
NUMOFTHREADS = 5
QUALTHRESHOLD = 30

all : platypus freebayes delly samtools gatk

platypus :
	mkdir -p $(OUTDIR)/Platypus/VCF/
	sh platypusRuns.sh $(BAMDIR) $(OUTDIR)/Platypus/VCF/ $(NUMOFTHREADS)
	sh processvcf.sh $(OUTDIR)/Platypus/VCF/ $(OUTDIR)/Platypus/ $(FIRSTVCF) $(SECONDVCF) $(NUMOFTHREADS)

freebayes :
	mkdir -p $(OUTDIR)/Freebayes/VCF/
	sh freebayesRuns.sh $(BAMDIR) $(OUTDIR)/Freebayes/VCF/ $(NUMOFTHREADS) $(QUALTHRESHOLD)
	sh processvcf.sh $(OUTDIR)/Freebayes/VCF/ $(OUTDIR)/Freebayes/ $(FIRSTVCF) $(SECONDVCF) $(NUMOFTHREADS)

delly :
	mkdir -p $(OUTDIR)/DELLY/VCF/
	sh dellyRuns.sh $(BAMDIR) $(OUTDIR)/DELLY/VCF/ $(NUMOFTHREADS)
	sh processvcf.sh $(OUTDIR)/DELLY/VCF/ $(OUTDIR)/DELLY/ $(FIRSTVCF) $(SECONDVCF) $(NUMOFTHREADS)

lumpy :
	mkdir -p $(OUTDIR)/LUMPY/VCF/
	sh lumpyRuns.sh $(BAMDIR) $(OUTDIR)/LUMPY/VCF/ $(NUMOFTHREADS)
	sh processvcf.sh $(OUTDIR)/LUMPY/VCF/ $(OUTDIR)/LUMPY/ $(FIRSTVCF) $(SECONDVCF) $(NUMOFTHREADS)

samtools :
	mkdir -p $(OUTDIR)/SAMTools/VCF/
	sh samtoolsRuns.sh $(BAMDIR) $(OUTDIR)/SAMTools/VCF/ $(NUMOFTHREADS) $(QUALTHRESHOLD)
	sh processvcf.sh $(OUTDIR)/SAMTools/VCF/ $(OUTDIR)/SAMTools/ $(FIRSTVCF) $(SECONDVCF) $(NUMOFTHREADS)

gatk :
	sh processvcf.sh $(OUTDIR)/GATK/VCF/ $(OUTDIR)/GATK/ $(FIRSTVCF) $(SECONDVCF) $(NUMOFTHREADS)

gasv :
	mkdir -p $(OUTDIR)/GASV/VCF/
	sh gasvRuns.sh $(BAMDIR) $(OUTDIR)/GASV/VCF/ $(QUALTHRESHOLD)

clean : cleanplatypus cleanfreebayes cleandelly cleanlumpy cleansamtools cleangatk cleangasv
	
cleanplatypus :
	rm -r -f $(OUTDIR)/Platypus/

cleanfreebayes :
	rm -r -f $(OUTDIR)/Freebayes/

cleandelly :
	rm -r -f $(OUTDIR)/DELLY/

cleanlumpy :
	rm -r -f $(OUTDIR)/LUMPY/

cleansamtools :
	rm -r -f $(OUTDIR)/Freebayes/

cleangatk :
	rm -r -f $(OUTDIR)/GATK/

cleangasv :
	rm -r -f $(OUTDIR)/GASV/
