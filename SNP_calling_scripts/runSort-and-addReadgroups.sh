#!/bin/bash
SAM="$1"
samtools view --threads 20 -b -o ${SAM%.*}.bam ${SAM}
samtools sort -o ${SAM%.*}_sorted.bam -T ${SAM%.*}_temp ${SAM%.*}.bam
REF="/home/FM/ysun/projects/Pedicularis-furbishiae/GBS/Pcr.genome.1.0.fasta"
ulimit -c unlimited
# example file looks like this:
# Z002E0081-SRR391089_sorted.bam
bam="${SAM%.*}_sorted.bam"
RGID=1
RGSM=$(basename $bam)
RGLB="${RGSM}-L001"
RGPU=001
echo -e "$RGID\t$RGSM\t$RGLB\t$RGPU"
java -Djava.io.tmpdir=$TMPDIR -Xmx50G -jar /home/FM/ysun/anaconda3/envs/GBS/share/picard-2.18.29-0/picard.jar AddOrReplaceReadGroups \
      I=${bam} \
      O=${bam%.*}_new.bam \
      RGID=$RGSM \
      RGLB=$RGLB \
      RGPL=ILLUMINA \
      RGPU=$RGPU \
      RGSM=$RGSM
samtools index ${bam%.*}_new.bam