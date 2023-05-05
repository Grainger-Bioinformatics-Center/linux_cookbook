# SNP Calling for GBS Data Pipeline

This pipeline is a prototype of calling SNPs using Genotyping-by-sequencing (GBS) data

## Software prerequisites

1) Stacks
2) BWA
3) samtools
4) Picard
5) VCFTools
6) Trimmomatic

## Data/resources

1) GBS sequencing data (fastq file)
2) Reference genome (fasta file)
3) Barcodes ID for GBS sequence (txt file)
4) Population map for all dataset (txt file)

## Installation of stacks

    cd ~/opt
	wget https://catchenlab.life.illinois.edu/stacks/source/stacks-2.62.tar.gz
    tar xfvz stacks-2.xx.tar.gz
    cd stacks-2.xx
	./configure --prefix=/path/to/opt/stacks-2.xx
    make -j 10

## Prepare for the dataset

trim and demultiplex the fastq file for the SNP calling

### Trim based on quality and adaptors
   
    trimmomatic-0.39.jar -d PE -fq FileNameSeed -t 10 -ph 33 -ad TruSeq3-PE.fa:2:30:10 -l 30 -sl 4:30 -tr 30 -m 32
	
### Demultiplex (scripts modified from GBS-SNP-CROP)
    
	# Demultiplexing Paired-End (PE) reads:
    perl GBS-Demultiplex.pl -d PE -b BarcodeID.txt -fq FileNameSeed
	# Demultiplexing Single-End (SE) reads:
	perl GBS-SNP-CROP-3.pl -d SE -b BarcodeID.txt -fq FileNameSeed

### Align reads to reference genome

    bwa index Pcr.genome.1.0.fasta
	bash GBS-bwa.sh

## SNP calling using stacks

Optinal using coordinate sorted bam file with readgroups added to the BAM header.

### Sort the bam files and add readgroups (required samtools and picard)

add readgroupsID readgroups readgroups-lane readgroups-sequence-method information to the bam files

    bash runSort-and-addReadgroups.sh

### Run gstacks for all sorted bam files

    ~/opt/stacks-2.62/gstacks -I ./ -M /path/to/pop-map/list -t 20 -O /path/to/output/b-gstacks/

### Run populations

analyze a population of individual samples computing a number of population genetics statistics.

    ~/opt/stacks-2.62/populations -t 20 -M /path/to/pop-map/list -P /path/to/gstacks/b-gstacks/ -O /path/to/output/c-populations --vcf --phylip --batch-size 10

### The results are in the c-population directory:

   populations.fixed.phylip
   populations.fixed.phylip.log
   populations.haplotypes.tsv
   populations.hapstats.tsv
   populations.haps.vcf
   populations.log
   populations.log.distribs
   populations.markers.tsv
   populations.snps.vcf
   populations.sumstats.tsv
   populations.sumstats_summary.tsv
