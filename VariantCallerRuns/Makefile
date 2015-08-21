BAMDIR = /home/cfirtina/VariantCallerTests/shufVsOrigBams/
REFFILE = /mnt/compgen/inhouse/share/gatk_bundle/2.8/b37/human_g1k_v37.fasta
OUTDIR = /home/cfirtina/VariantCallerTests/ShufVsOrig/
FIRSTVCF = orig
SECONDVCF = shuf

platypus :
	mkdir -p $(OUTDIR)/Platypus/VCF/
	sh platypusRuns.sh $(BAMDIR) $(OUTDIR)/Platypus/VCF/
	sh processvcf.sh $(OUTDIR)/Platypus/VCF/ $(OUTDIR)/Platypus/ $(FIRSTVCF) $(SECONDVCF)

freebayes :
	mkdir -p $(OUTDIR)/Freebayes/VCF/
	sh freebayesRuns.sh $(BAMDIR) $(OUTDIR)/Freebayes/VCF/ 30
	sh processvcf.sh $(OUTDIR)/Freebayes/VCF/ $(OUTDIR)/Freebayes/ $(FIRSTVCF) $(SECONDVCF)

delly :
	mkdir -p $(OUTDIR)/DELLY/VCF/
	sh dellyRuns.sh $(BAMDIR) $(OUTDIR)/DELLY/VCF/
	sh processvcf.sh $(OUTDIR)/DELLY/VCF/ $(OUTDIR)/DELLY/ $(FIRSTVCF) $(SECONDVCF)

lumpy :
	mkdir -p $(OUTDIR)/LUMPY/VCF/
	sh lumpyRuns.sh $(BAMDIR) $(OUTDIR)/LUMPY/VCF/
	sh processvcf.sh $(OUTDIR)/LUMPY/VCF/ $(OUTDIR)/LUMPY/ $(FIRSTVCF) $(SECONDVCF)

samtools :
	mkdir -p $(OUTDIR)/SAMTools/VCF/
	sh samtoolsRuns.sh $(BAMDIR) $(OUTDIR)/SAMTools/VCF/ 30
	sh processvcf.sh $(OUTDIR)/SAMTools/VCF/ $(OUTDIR)/SAMTools/ $(FIRSTVCF) $(SECONDVCF)

gatk :
	sh processvcf.sh $(OUTDIR)/GATK/VCF/ $(OUTDIR)/GATK/ $(FIRSTVCF) $(SECONDVCF)

clean : cleanplatypus cleanfreebayes cleandelly cleanlumpy cleansamtools cleangatk
	
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
