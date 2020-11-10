#!/bin/bash

REF_GENOME_FA=$1
BED_WITH_TARGETS=$2
TUMOUR_DEEP_SEQ_BAM=$3
NORMAL_DEEP_SEQ_BAM=$4
INDEL_VCF=$5
DONOR_ID=$6
WORK_DIR=$7

mkdir -p $WORK_DIR/$DONOR_ID

# get calls within captured regions
selected_vcf="$WORK_DIR/$DONOR_ID/selected-`basename $INDEL_VCF`"
gatk SelectVariants -R $REF_GENOME_FA -V $INDEL_VCF -L $BED_WITH_TARGETS -O $selected_vcf

# ge PASS only calls
pass_vcf="$WORK_DIR/$DONOR_ID/pass-only-`basename $INDEL_VCF`"
gatk SelectVariants -R $REF_GENOME_FA -V $selected_vcf --exclude-filtered true -O $pass_vcf


# split multi-allelic to bi-allelic
bi_allelic_vcf="$WORK_DIR/$DONOR_ID/bi-allelic-pass-only-`basename $INDEL_VCF`"
vcfbreakmulti $pass_vcf > $bi_allelic_vcf

# run sga to add read counts
input_vcf_name=$(basename $INDEL_VCF .gz)
annotated_vcf="$WORK_DIR/$DONOR_ID/annotated-$input_vcf_name"
docker run --rm -v `pwd`:`pwd` -w `pwd` --entrypoint=/bin/bash quay.io/icgc-argo/sga:0.10.15 -c "sga somatic-variant-filters \
    --threads 4 --annotate-only --tumor-bam $TUMOUR_DEEP_SEQ_BAM --normal-bam $NORMAL_DEEP_SEQ_BAM \
    --reference $REF_GENOME_FA $bi_allelic_vcf |  sed -e 's/TumorVAF=[0-9\.]*;//' -e 's/NormalVAF=[0-9\.]*;//' \
    -e 's/[35]pContext=[0-9\.]*;//' -e 's/RepeatUnit=[ACTT]*;//' -e 's/RepeatRefCount=[0-9]*;//' \
    -e 's/TumorVarDepth/TumourEvidenceReads/' -e 's/NormalVarDepth/NormalEvidenceReads/' \
    -e 's/TumorTotalDepth/TumourReads/' -e 's/NormalTotalDepth/NormalReads/' \
    -e 's/;;/;/' " | grep -v 'sga::somatic-variant-filters' > $annotated_vcf
