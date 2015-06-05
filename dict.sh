#!/bin/bash 

# path to ru4sphinx repo
RU4SPHINX=$1
# path to the dictionary file
DIC=$2
# path to output
OUT=$3

# Generate .dic file
perl $RU4SPHINX/text2dict/dict2transcript.pl $DIC $OUT.dic
