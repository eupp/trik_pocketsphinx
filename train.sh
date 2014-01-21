#!/bin/bash 

# path to adapted model
ACOUSTIC_MODEL=$1
# path to directory for output
ADAPTED_MODEL=$2
# path to ru4sphinx repo
RU4SPHINX=$3
# path to the dictionary file
DIC=$4
# path to the text file with list of .wav files which will be used during the adaptation
FILEIDS=$5
# path to the file with trancriptions of .wav files
TRANSC=$6
# path to sphinxtrain utils (/usr/local/libexec/sphinxtrain by default)
SPHINXTRAIN=$7

if [ ! $SPHINXTRAIN ]
then
	SPHINXTRAIN=/usr/local/libexec/sphinxtrain
fi

# Generate .dic file
perl $RU4SPHINX/text2dict/dict2transcript.pl $DIC $ADAPTED_MODEL/$DIC.dic

# Generate acoustic model features from our .wav files
# we must set feat.params file of our acoustic model and .fileids file with list of .wav files
sphinx_fe \
 -argfile $ACOUSTIC_MODEL/feat.params \
 -samprate 16000 \
 -c commands.fileids \
 -di . \
 -do . \
 -ei wav \
 -eo mfc \
 -mswav yes

# Accumulating observation counts

$SPHINXTRAIN/bw \
 -hmmdir $ACOUSTIC_MODEL \
 -moddeffn $ACOUSTIC_MODEL/mdef.txt \
 -ts2cbfn .cont. \
 -feat 1s_c_d_dd \
 -cmn current \
 -agc none \
 -dictfn $ADAPTED_MODEL/$DIC.dic \
 -ctlfn $FILEIDS \
 -lsnfn $TRANSC \
 -accumdir .

# MLLR adaptation

$SPHINXTRAIN/mllr_solve \
    -meanfn $ACOUSTIC_MODEL/means \
    -varfn $ACOUSTIC_MODEL/variances \
    -outmllrfn mllr_matrix -accumdir .
mv mllr_matrix $ADAPTED_MODEL/

# Map adaptation

mkdir $ADAPTED_MODEL/acoustic
cp $ACOUSTIC_MODEL/* $ADAPTED_MODEL/acoustic/ 
$SPHINXTRAIN/map_adapt \
    -meanfn $ACOUSTIC_MODEL/means \
    -varfn $ACOUSTIC_MODEL/variances \
    -mixwfn $ACOUSTIC_MODEL/mixture_weights \
    -tmatfn $ACOUSTIC_MODEL/transition_matrices \
    -accumdir . \
    -mapmeanfn $ADAPTED_MODEL/acoustic/means \
    -mapvarfn $ADAPTED_MODEL/acoustic/variances \
    -mapmixwfn $ADAPTED_MODEL/acoustic/mixture_weights \
    -maptmatfn $ADAPTED_MODEL/acoustic/transition_matrices

# Create sendump file 

$SPHINXTRAIN/mk_s2sendump \
    -pocketsphinx yes \
    -moddeffn $ADAPTED_MODEL/acoustic/mdef.txt \
    -mixwfn $ADAPTED_MODEL/acoustic/mixture_weights \
    -sendumpfn $ADAPTED_MODEL/sendump

