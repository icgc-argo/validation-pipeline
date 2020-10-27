#!/bin/bash

## INPUTS
# 1. reference genome: GRCh38
# 2. BED file with targeted regions (lifted from GRCh37)
# 3. aligned targeted deep sequencing BAMs for tumour and matched normal
# 4. VCF with SNV calls to be validated
# 5. VCF with InDel calls to be validated

## OUTPUTS
# 1. SNV variant VCF with annotations such as NormalReads; TumourReads; NormalEvidenceReads; TumourEvidenceReads and filter flags 
# 2. InDel variant VCF with annotations similar to SNV VCF, also: 3pContext, 5pContext, RepeatRefCount, RepeatRefCount


## Major steps
# 1. get BAM stats, BAM depth (run-bam-stats, input: lifted BED for captured regions, aligned target seq bams)
# 2. build BED files (input: variant call VCFs, lifted BED for captured regions)
# 3. add read counts for SNVs (run-readcounts, input: bed, bams)
# 4. add SGA annotation for InDels (run-sga-annotate, input: vcf (selected region only), bams)
# 5. add read counts for SVs (run-sv-count), not now
# 6. make calls (run-call, input: count annotated vcf), ie, categorize each call into LOWDEPTH, NOTSEEN, STRANDBIAS, NORMALEVIDENCE, GERMLINE, PASS

