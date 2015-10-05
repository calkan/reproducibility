#!/bin/bash
VCFSOURCEDIR=$1 #(required) directory where vcf files exist. Your files should end with .vcf to be processed by this script. It processes all the vcf files in this directory
DESTDIR=$2 #(required) base directory where the results will be located
DIFFFIRSTFILE=$3 #(required)This script is designed to compare two vcf files. Therefore these two files should have exactly the same name except a pattern that creates the difference between two files. For example HG00006.orig.vcf and HG00096.shuf.vcf. Only differences are orig and shuf here. This argument takes the string that creates the difference in first file (orig, for the example).
DIFFSECONDFILE=$4 #(required) second file's difference. (see DIFFFIRSTFILE for the detailed explanation)
NUMOFTHREADS=$5 #(required) number of threads allowed for this script
BEDSOURCEDIR="/mnt/storage1/projects/shuffle/GATK/b37/"
ORIGDIR="$DESTDIR/noIntersectBed/"
GENESFILENAME="b37_genes.bed"
EXONSFILENAME="b37_exons.bed"
DUPSFILENAME="build37.dups.bed"
REPSFILENAME="build37.reps.bed"
SNPFILE="/mnt/compgen/inhouse/share/gatk_bundle/2.8/b37/dbsnp_138.b37.vcf"

#create hom, het, snvs, indels
countThreads=0
mkdir $ORIGDIR
HOMDIR="$ORIGDIR/hom"
mkdir $HOMDIR
for i in `ls $VCFSOURCEDIR/*.vcf*`; do fname=`basename $i`; grep "1/1" $i > "$HOMDIR/$fname.hom" &
countThreads=$((countThreads+1))
if [ "$countThreads" -eq "$NUMOFTHREADS" ]; then
        wait
        countThreads=0
fi
done;

HETDIR="$ORIGDIR/het"
mkdir $HETDIR
for i in `ls $VCFSOURCEDIR/*.vcf*`; do fname=`basename $i`; grep "0/1" $i > "$HETDIR/$fname.het" &
countThreads=$((countThreads+1))
if [ "$countThreads" -eq "$NUMOFTHREADS" ]; then
        wait
        countThreads=0
fi
done;

SNVDIR="$ORIGDIR/snv"
mkdir $SNVDIR
for i in `ls $VCFSOURCEDIR/*.vcf*`; do fname=`basename $i`; awk 'BEGIN{OFS = "\t"}; { if (length($4) ==  length($5)) print };' $i > "$SNVDIR/$fname.snv" &
countThreads=$((countThreads+1))
if [ "$countThreads" -eq "$NUMOFTHREADS" ]; then
        wait
        countThreads=0
fi
done;

INDELDIR="$ORIGDIR/indel"
mkdir $INDELDIR
for i in `ls $VCFSOURCEDIR/*.vcf*`; do fname=`basename $i`; awk 'BEGIN{OFS = "\t"}; { if (length($4) !=  length($5)) print };' $i > "$INDELDIR/$fname.indel" &
countThreads=$((countThreads+1))
if [ "$countThreads" -eq "$NUMOFTHREADS" ]; then
        wait
        countThreads=0
fi
done;

SNPDIR="$ORIGDIR/dbsnps"
mkdir $SNPDIR
for i in `ls $VCFSOURCEDIR/*.vcf*`; do fname=`basename $i`; intersectBed -header -f 1.0 -r -a $i -b $SNPFILE | uniq -w 50 > "$SNPDIR/$fname.dbsnp" &
countThreads=$((countThreads+1))
if [ "$countThreads" -eq "$NUMOFTHREADS" ]; then
        wait
        countThreads=0
fi
done;
wait
countThreads=0

#create tsvs
for i in `ls $VCFSOURCEDIR/*.vcf*`; do fname=`basename $i`; grep -v \# $i | cut -f 1,2,3,10 | sed s/":"/"\t"/ | cut -f 1,2,3,4 | sort -k 1,1 -k 2,2n > "$ORIGDIR/$fname.tsv" &
countThreads=$((countThreads+1))
if [ "$countThreads" -eq "$NUMOFTHREADS" ]; then
        wait
        countThreads=0
fi
done;
for i in `ls $HOMDIR/*.hom`; do fname=`basename $i`; grep -v \# $i | cut -f 1,2,3,10 | sed s/":"/"\t"/ | cut -f 1,2,3,4 | sort -k 1,1 -k 2,2n > "$HOMDIR/$fname.tsv" &
countThreads=$((countThreads+1))
if [ "$countThreads" -eq "$NUMOFTHREADS" ]; then
        wait
        countThreads=0
fi
done;
for i in `ls $HETDIR/*.het`; do fname=`basename $i`; grep -v \# $i | cut -f 1,2,3,10 | sed s/":"/"\t"/ | cut -f 1,2,3,4 | sort -k 1,1 -k 2,2n > "$HETDIR/$fname.tsv" &
countThreads=$((countThreads+1))
if [ "$countThreads" -eq "$NUMOFTHREADS" ]; then
        wait
        countThreads=0
fi
done;
for i in `ls $SNVDIR/*.snv`; do fname=`basename $i`; grep -v \# $i | cut -f 1,2,3,10 | sed s/":"/"\t"/ | cut -f 1,2,3,4 | sort -k 1,1 -k 2,2n > "$SNVDIR/$fname.tsv" &
countThreads=$((countThreads+1))
if [ "$countThreads" -eq "$NUMOFTHREADS" ]; then
        wait
        countThreads=0
fi
done;
for i in `ls $INDELDIR/*.indel`; do fname=`basename $i`; grep -v \# $i | cut -f 1,2,3,10 | sed s/":"/"\t"/ | cut -f 1,2,3,4 | sort -k 1,1 -k 2,2n > "$INDELDIR/$fname.tsv" &
countThreads=$((countThreads+1))
if [ "$countThreads" -eq "$NUMOFTHREADS" ]; then
        wait
        countThreads=0
fi
done;
for i in `ls $SNPDIR/*.dbsnp`; do fname=`basename $i`; grep -v \# $i | cut -f 1,2,3,10 | sed s/":"/"\t"/ | cut -f 1,2,3,4 | sort -k 1,1 -k 2,2n > "$SNPDIR/$fname.tsv" &
countThreads=$((countThreads+1))
if [ "$countThreads" -eq "$NUMOFTHREADS" ]; then
        wait
        countThreads=0
fi
done;
wait

countThreads=0
#create diffs
for j in $ORIGDIR $HOMDIR $HETDIR $SNVDIR $INDELDIR $SNPDIR; do
	mkdir "$j/diff"
	for i in `ls $j/*.tsv`; do fname=`basename $i`;
		if (echo "$fname" | grep -q ".$DIFFSECONDFILE.") then
			opFName="$(echo "$fname" | sed s/".$DIFFSECONDFILE."/".$DIFFFIRSTFILE."/)"
		else
			opFName="$(echo "$fname" | sed s/".$DIFFFIRSTFILE."/".$DIFFSECONDFILE."/)"
		fi

		diff "$j/$fname" "$j/$opFName" | grep "<" | sed 's/^<//g' > "$j/diff/$fname.diff" &
		countThreads=$((countThreads+1))
		if [ "$countThreads" -eq "$NUMOFTHREADS" ]; then
		        wait
		        countThreads=0
		fi
	done;
done;

wait
countThreads=0
#create genes, exons, reps, dups intersection vcfs
for j in $GENESFILENAME $EXONSFILENAME $DUPSFILENAME $REPSFILENAME; do mkdir "$DESTDIR/$j";
	for i in `ls $VCFSOURCEDIR/*.vcf*`; do fname=`basename $i`; intersectBed -header -a $i -b "$BEDSOURCEDIR/$j" > "$DESTDIR/$j/$fname.$j" &
	countThreads=$((countThreads+1))
	if [ "$countThreads" -eq "$NUMOFTHREADS" ]; then
	        wait
	        countThreads=0
	fi
	done;
	wait
	countThreads=0
	CURCALLSETDIR="$DESTDIR/$j/"
	INTRSCTHOMDIR="$CURCALLSETDIR/hom"
	mkdir $INTRSCTHOMDIR
	for i in `ls $CURCALLSETDIR/*.$j`; do fname=`basename $i`; grep "1/1" $i > "$INTRSCTHOMDIR/$fname.hom" &
	countThreads=$((countThreads+1))
	if [ "$countThreads" -eq "$NUMOFTHREADS" ]; then
	        wait
	        countThreads=0
	fi
	done;

	INTRSCTHETDIR="$CURCALLSETDIR/het"
	mkdir $INTRSCTHETDIR
	for i in `ls $CURCALLSETDIR/*.$j`; do fname=`basename $i`; grep "0/1" $i > "$INTRSCTHETDIR/$fname.het" &
	countThreads=$((countThreads+1))
	if [ "$countThreads" -eq "$NUMOFTHREADS" ]; then
	        wait
	        countThreads=0
	fi
	done;

	INTRSCTSNVDIR="$CURCALLSETDIR/snv"
	mkdir $INTRSCTSNVDIR
	for i in `ls $CURCALLSETDIR/*.$j`; do fname=`basename $i`; awk 'BEGIN{OFS = "\t"}; { if (length($4) ==  length($5)) print };' $i > "$INTRSCTSNVDIR/$fname.snv" &
	countThreads=$((countThreads+1))
	if [ "$countThreads" -eq "$NUMOFTHREADS" ]; then
	        wait
	        countThreads=0
	fi
	done;

	INTRSCTINDELDIR="$CURCALLSETDIR/indel"
	mkdir $INTRSCTINDELDIR
	for i in `ls $CURCALLSETDIR/*.$j`; do fname=`basename $i`; awk 'BEGIN{OFS = "\t"}; { if (length($4) !=  length($5)) print };' $i > "$INTRSCTINDELDIR/$fname.indel" &
	countThreads=$((countThreads+1))
	if [ "$countThreads" -eq "$NUMOFTHREADS" ]; then
	        wait
	        countThreads=0
	fi
	done;

	INTRSCTSNPDIR="$CURCALLSETDIR/dbsnps"
	mkdir $INTRSCTSNPDIR
	for i in `ls $CURCALLSETDIR/*.$j`; do fname=`basename $i`; intersectBed -header -f 1.0 -r -a $i -b $SNPFILE | uniq -w 50 > "$INTRSCTSNPDIR/$fname.dbsnp"  &
	countThreads=$((countThreads+1))
	if [ "$countThreads" -eq "$NUMOFTHREADS" ]; then
	        wait
	        countThreads=0
	fi
	done;
	wait
	countThreads=0

	for i in `ls $CURCALLSETDIR/*.$j`; do fname=`basename $i`; grep -v \# $i | cut -f 1,2,3,10 | sed s/":"/"\t"/ | cut -f 1,2,3,4 | sort -k 1,1 -k 2,2n > "$CURCALLSETDIR/$fname.tsv" &
	countThreads=$((countThreads+1))
	if [ "$countThreads" -eq "$NUMOFTHREADS" ]; then
	        wait
	        countThreads=0
	fi
	done;

	for i in `ls $INTRSCTHOMDIR/*.$j.hom`; do fname=`basename $i`; grep -v \# $i | cut -f 1,2,3,10 | sed s/":"/"\t"/ | cut -f 1,2,3,4 | sort -k 1,1 -k 2,2n > "$INTRSCTHOMDIR/$fname.tsv" &
	countThreads=$((countThreads+1))
	if [ "$countThreads" -eq "$NUMOFTHREADS" ]; then
	        wait
	        countThreads=0
	fi
	done;

	for i in `ls $INTRSCTHETDIR/*.$j.het`; do fname=`basename $i`; grep -v \# $i | cut -f 1,2,3,10 | sed s/":"/"\t"/ | cut -f 1,2,3,4 | sort -k 1,1 -k 2,2n > "$INTRSCTHETDIR/$fname.tsv" &
	countThreads=$((countThreads+1))
	if [ "$countThreads" -eq "$NUMOFTHREADS" ]; then
	        wait
	        countThreads=0
	fi
	done;

	for i in `ls $INTRSCTSNVDIR/*.$j.snv`; do fname=`basename $i`; grep -v \# $i | cut -f 1,2,3,10 | sed s/":"/"\t"/ | cut -f 1,2,3,4 | sort -k 1,1 -k 2,2n > "$INTRSCTSNVDIR/$fname.tsv" &
	countThreads=$((countThreads+1))
	if [ "$countThreads" -eq "$NUMOFTHREADS" ]; then
	        wait
	        countThreads=0
	fi
	done;

	for i in `ls $INTRSCTINDELDIR/*.$j.indel`; do fname=`basename $i`; grep -v \# $i | cut -f 1,2,3,10 | sed s/":"/"\t"/ | cut -f 1,2,3,4 | sort -k 1,1 -k 2,2n > "$INTRSCTINDELDIR/$fname.tsv" &
	countThreads=$((countThreads+1))
	if [ "$countThreads" -eq "$NUMOFTHREADS" ]; then
	        wait
	        countThreads=0
	fi
	done;

	for i in `ls $INTRSCTSNPDIR/*.$j.dbsnp`; do fname=`basename $i`; grep -v \# $i | cut -f 1,2,3,10 | sed s/":"/"\t"/ | cut -f 1,2,3,4 | sort -k 1,1 -k 2,2n > "$INTRSCTSNPDIR/$fname.tsv" &
	countThreads=$((countThreads+1))
	if [ "$countThreads" -eq "$NUMOFTHREADS" ]; then
	        wait
	        countThreads=0
	fi
	done;

	wait
	countThreads=0
	#create diffs
	for k in $CURCALLSETDIR $INTRSCTHOMDIR $INTRSCTHETDIR $INTRSCTSNVDIR $INTRSCTINDELDIR $INTRSCTSNPDIR; do
		mkdir "$k/diff"
		for l in `ls $k/*.tsv`; do fname=`basename $l`;
			if (echo "$fname" | grep -q ".$DIFFSECONDFILE.") then
				opFName="$(echo "$fname" | sed s/".$DIFFSECONDFILE."/".$DIFFFIRSTFILE."/)"
			else
				opFName="$(echo "$fname" | sed s/".$DIFFFIRSTFILE."/".$DIFFSECONDFILE."/)"
			fi

			diff "$k/$fname" "$k/$opFName" | grep "<" | sed 's/^<//g' > "$k/diff/$fname.diff" &
			countThreads=$((countThreads+1))
			if [ "$countThreads" -eq "$NUMOFTHREADS" ]; then
			        wait
			        countThreads=0
			fi
		done;
	done;
done;
