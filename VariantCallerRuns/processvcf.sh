#!/bin/bash
VCFSOURCEDIR=$1
DESTDIR=$2
DIFFFIRSTFILE=$3
DIFFSECONDFILE=$4
QUALTHRESHOLD=$5
BEDSOURCEDIR="/mnt/storage1/projects/shuffle/GATK/b37/"
ORIGDIR="$DESTDIR/noIntersectBed/"
GENESFILENAME="b37_genes.bed"
EXONSFILENAME="b37_exons.bed"
DUPSFILENAME="build37.dups.bed"
REPSFILENAME="build37.reps.bed"

#qual filter
if [ "$#" -gt 4 ]; then
	mkdir $VCFSOURCEDIR/filtered/
	for i in `ls $VCFSOURCEDIR/*.vcf*`; do fname=`basename $i`; cat $i | awk -F'\t' '{if($6 >= qual || substr($1,1,1) == "#") print $0;}' qual="$QUALTHRESHOLD" > "$VCFSOURCEDIR/filtered/$fname.filtered"; done;
	VCFSOURCEDIR=$VCFSOURCEDIR/filtered/
fi
#create hom, het, snvs, indels
mkdir $ORIGDIR
HOMDIR="$ORIGDIR/hom"
mkdir $HOMDIR
for i in `ls $VCFSOURCEDIR/*.vcf*`; do fname=`basename $i`; grep "1/1" $i > "$HOMDIR/$fname.hom"; done;

HETDIR="$ORIGDIR/het"
mkdir $HETDIR
for i in `ls $VCFSOURCEDIR/*.vcf*`; do fname=`basename $i`; grep "0/1" $i > "$HETDIR/$fname.het"; done;

SNVDIR="$ORIGDIR/snv"
mkdir $SNVDIR
for i in `ls $VCFSOURCEDIR/*.vcf*`; do fname=`basename $i`; awk 'BEGIN{OFS = "\t"}; { if (length($4) ==  length($5)) print };' $i > "$SNVDIR/$fname.snv"; done;

INDELDIR="$ORIGDIR/indel"
mkdir $INDELDIR
for i in `ls $VCFSOURCEDIR/*.vcf*`; do fname=`basename $i`; awk 'BEGIN{OFS = "\t"}; { if (length($4) !=  length($5)) print };' $i > "$INDELDIR/$fname.indel"; done;

#create tsvs
for i in `ls $VCFSOURCEDIR/*.vcf*`; do fname=`basename $i`; grep -v \# $i | cut -f 1,2,3,10 | sed s/":"/"\t"/ | cut -f 1,2,3,4 | sort -k 1,1 -k 2,2n > "$ORIGDIR/$fname.tsv"; done;
for i in `ls $HOMDIR/*.hom`; do fname=`basename $i`; grep -v \# $i | cut -f 1,2,3,10 | sed s/":"/"\t"/ | cut -f 1,2,3,4 | sort -k 1,1 -k 2,2n > "$HOMDIR/$fname.tsv"; done;
for i in `ls $HETDIR/*.het`; do fname=`basename $i`; grep -v \# $i | cut -f 1,2,3,10 | sed s/":"/"\t"/ | cut -f 1,2,3,4 | sort -k 1,1 -k 2,2n > "$HETDIR/$fname.tsv"; done;
for i in `ls $SNVDIR/*.snv`; do fname=`basename $i`; grep -v \# $i | cut -f 1,2,3,10 | sed s/":"/"\t"/ | cut -f 1,2,3,4 | sort -k 1,1 -k 2,2n > "$SNVDIR/$fname.tsv"; done;
for i in `ls $INDELDIR/*.indel`; do fname=`basename $i`; grep -v \# $i | cut -f 1,2,3,10 | sed s/":"/"\t"/ | cut -f 1,2,3,4 | sort -k 1,1 -k 2,2n > "$INDELDIR/$fname.tsv"; done;

#create diffs
for j in $ORIGDIR $HOMDIR $HETDIR $SNVDIR $INDELDIR; do
	mkdir "$j/diff"
	for i in `ls $j/*.tsv`; do fname=`basename $i`;
		if (echo "$fname" | grep -q ".$DIFFSECONDFILE.") then
			opFName="$(echo "$fname" | sed s/".$DIFFSECONDFILE."/".$DIFFFIRSTFILE."/)"
		else
			opFName="$(echo "$fname" | sed s/".$DIFFFIRSTFILE."/".$DIFFSECONDFILE."/)"
		fi

		diff "$j/$fname" "$j/$opFName" | grep "<" | sed 's/^<//g' > "$j/diff/$fname.diff";
	done;
done;

#create genes, exons, reps, dups intersection vcfs
for j in $GENESFILENAME $EXONSFILENAME $DUPSFILENAME $REPSFILENAME; do mkdir "$DESTDIR/$j";
	for i in `ls $VCFSOURCEDIR/*.vcf*`; do fname=`basename $i`; intersectBed -a $i -b "$BEDSOURCEDIR/$j" > "$DESTDIR/$j/$fname.$j"; done;
	
	CURCALLSETDIR="$DESTDIR/$j/"
	INTRSCTHOMDIR="$CURCALLSETDIR/hom"
	mkdir $INTRSCTHOMDIR
	for i in `ls $CURCALLSETDIR/*.$j`; do fname=`basename $i`; grep "1/1" $i > "$INTRSCTHOMDIR/$fname.hom"; done;

	INTRSCTHETDIR="$CURCALLSETDIR/het"
	mkdir $INTRSCTHETDIR
	for i in `ls $CURCALLSETDIR/*.$j`; do fname=`basename $i`; grep "0/1" $i > "$INTRSCTHETDIR/$fname.het"; done;

	INTRSCTSNVDIR="$CURCALLSETDIR/snv"
	mkdir $INTRSCTSNVDIR
	for i in `ls $CURCALLSETDIR/*.$j`; do fname=`basename $i`; awk 'BEGIN{OFS = "\t"}; { if (length($4) ==  length($5)) print };' $i > "$INTRSCTSNVDIR/$fname.snv"; done;

	INTRSCTINDELDIR="$CURCALLSETDIR/indel"
	mkdir $INTRSCTINDELDIR
	for i in `ls $CURCALLSETDIR/*.$j`; do fname=`basename $i`; awk 'BEGIN{OFS = "\t"}; { if (length($4) !=  length($5)) print };' $i > "$INTRSCTINDELDIR/$fname.indel"; done;

	for i in `ls $CURCALLSETDIR/*.$j`; do fname=`basename $i`; grep -v \# $i | cut -f 1,2,3,10 | sed s/":"/"\t"/ | cut -f 1,2,3,4 | sort -k 1,1 -k 2,2n > "$CURCALLSETDIR/$fname.tsv"; done;
	for i in `ls $INTRSCTHOMDIR/*.$j.hom`; do fname=`basename $i`; grep -v \# $i | cut -f 1,2,3,10 | sed s/":"/"\t"/ | cut -f 1,2,3,4 | sort -k 1,1 -k 2,2n > "$INTRSCTHOMDIR/$fname.tsv"; done;
	for i in `ls $INTRSCTHETDIR/*.$j.het`; do fname=`basename $i`; grep -v \# $i | cut -f 1,2,3,10 | sed s/":"/"\t"/ | cut -f 1,2,3,4 | sort -k 1,1 -k 2,2n > "$INTRSCTHETDIR/$fname.tsv"; done;
	for i in `ls $INTRSCTSNVDIR/*.$j.snv`; do fname=`basename $i`; grep -v \# $i | cut -f 1,2,3,10 | sed s/":"/"\t"/ | cut -f 1,2,3,4 | sort -k 1,1 -k 2,2n > "$INTRSCTSNVDIR/$fname.tsv"; done;
	for i in `ls $INTRSCTINDELDIR/*.$j.indel`; do fname=`basename $i`; grep -v \# $i | cut -f 1,2,3,10 | sed s/":"/"\t"/ | cut -f 1,2,3,4 | sort -k 1,1 -k 2,2n > "$INTRSCTINDELDIR/$fname.tsv"; done;

	#create diffs
	for k in $CURCALLSETDIR $INTRSCTHOMDIR $INTRSCTHETDIR $INTRSCTSNVDIR $INTRSCTINDELDIR; do
		mkdir "$k/diff"
		for l in `ls $k/*.tsv`; do fname=`basename $l`;
			if (echo "$fname" | grep -q ".$DIFFSECONDFILE.") then
				opFName="$(echo "$fname" | sed s/".$DIFFSECONDFILE."/".$DIFFFIRSTFILE."/)"
			else
				opFName="$(echo "$fname" | sed s/".$DIFFFIRSTFILE."/".$DIFFSECONDFILE."/)"
			fi

			diff "$k/$fname" "$k/$opFName" | grep "<" | sed 's/^<//g' > "$k/diff/$fname.diff";
		done;
	done;
done;
