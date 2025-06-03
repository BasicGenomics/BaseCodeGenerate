#!/bin/bash
filename=$1
filename_base="${filename%.*}"
outfile_pos="${filename_base}.positive.gff3"
outfile_neg="${filename_base}.negative.gff3"
awk -F'\t' '{if ($7=="+" || $0 ~ /^#!*/) print $0}' ${filename} > ${outfile_pos}
awk -F'\t' '{if ($7=="-" || $0 ~ /^#!*/) print $0}' ${filename} > ${outfile_neg}