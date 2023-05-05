#!/bin/bash
FILES=*_R1_.fq.gz
for f in $FILES
do
echo "Processing $f ..."
file=${f%%_R1_.fq.gz}
name=${file##*/}
forward=${name}_R1_.fq.gz
reverse=${name}_R2_.fq.gz
index=/home/FM/ysun/projects/Pedicularis-furbishiae/GBS/Pcr.genome.1.0.fasta
bwa mem -t 20 -M ${index} ${forward} ${reverse} > a-alignments/${name}.sam
done