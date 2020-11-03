#!/bin/bash

REF_GENOME_FA=$1
BAM=$2
BED=$3
OUTDIR=$4

mkdir -p $OUTDIR

out_file="$(basename $BAM).target_coverage"

gatk DepthOfCoverage -R $REF_GENOME_FA -I $BAM -L $BED -O $OUTDIR/$out_file
