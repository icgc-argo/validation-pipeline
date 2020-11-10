#!/bin/bash

## INPUTS
# 1. reference genome: GRCh38
# 2. donor level BED file with targeted regions (lifted from GRCh37)
# 3. aligned targeted deep sequencing BAMs for tumour and matched normal samples
# 4. VCF with SNV calls to be validated
# 5. VCF with InDel calls to be validated

## OUTPUTS
# 1. SNV variant VCF with annotations such as NormalReads; TumourReads; NormalEvidenceReads; TumourEvidenceReads and filter flags 
# 2. InDel variant VCF with annotations similar to SNV VCF, also: 3pContext, 5pContext, RepeatRefCount, RepeatRefCount


## Major steps
# 1. get BAM depth stats (original script bam-depth.sh, input: lifted BED for captured regions, aligned target seq bams)
# 2. add read counts for SNVs (original script one-readcount.sh, input: SNV vcf, bams)
# 3. categorize each SNV call into LOWDEPTH, NOTSEEN, STRANDBIAS, NORMALEVIDENCE, GERMLINE,
#    PASS (original script snv_readcounts.py, input: selected SNV VCF, normal readcount, tumour read count)
# 4. add SGA annotation for InDels (original script one-sga-annotate.sh, input: InDel vcf (selected region only), bams)
# 5. categorize each InDel call into LOWDEPTH, NOTSEEN, STRANDBIAS, NORMALEVIDENCE, GERMLINE,
#    PASS (original script snv_indel_call.py, input: annotated InDel VCF produced by the previous step)
# 6. (later) add read counts for SVs (original script count-sv-support.py, input: SV vcf (selected region only), bams)
# 7. (later) categorize each SV call into LOWDEPTH, NOTSEEN, STRANDBIAS, NORMALEVIDENCE, GERMLINE,
#    PASS (original script sv_call.py, input: annotated SV VCF produced by the previous step)


# input params
if [ ! $# -eq 9 ]
then
    echo "$0 - performs validation on SNV/INDEL calls by verifying against deep targeted sequencing data"
    echo "Usage: $0 REF_GENOME_FA BED_WITH_TARGETS TUMOUR_DEEP_SEQ_BAM NORMAL_DEEP_SEQ_BAM SNV_VCF INDEL_VCF DONOR_ID WORK_DIR OUTPUT_DIR"
    echo
    exit
fi

REF_GENOME_FA=$1
BED_WITH_TARGETS=$2
TUMOUR_DEEP_SEQ_BAM=$3
NORMAL_DEEP_SEQ_BAM=$4
SNV_VCF=$5
INDEL_VCF=$6
DONOR_ID=$7
WORK_DIR=$8
OUTPUT_DIR=$9
