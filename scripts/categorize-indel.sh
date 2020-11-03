#!/bin/bash

INPUT_VCF=$1
OUTPUT_DIR=$2

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

python3 $DIR/../original/scripts/snv_indel_call.py --error 0.01 --callthreshold 0.02 --mindepth 30 \
    --strandbias -1 --germlineprob 0.01 -i $INPUT_VCF > $OUTPUT_DIR/categorized-`basename $INPUT_VCF`
