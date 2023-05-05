# Genome Assembly Instruction

This pipeline is a prototype of genome assembly using Lichen genome as an example.

## Reads trimming/filtering (optional)

Reads trimming/filtering are usually using Trimmomatic (for short reads-usually Illumina reads) and Filtlong (for long reads)

### Trimmomatic trimming

**Trim the pair ends reads:**

    trimmomatic PE -threads 16 -phred33 -trimlog trim.log reads_R1.fastq reads_R2.fastq reads_trim_R1.fastq reads_unpair_R1.fastq reads_trim_R2.fastq reads_unpair_R2.fastq LEADING:10 TRAILING:10 ILLUMINACLIP:/path_to_your_trimmomatic/trimmomatic-0.39-1/adapters/TruSeq3-PE.fa/:2:30:10

**Trim the single end reads:**

    trimmomatic SE -threads 16 -phred33 -trimlog trim.log reads.fastq reads_trim.fastq LEADING:10 TRAILING:10 ILLUMINACLIP:/path_to_your_trimmomatic/trimmomatic-0.39-1/adapters/TruSeq3-PE.fa/:2:30:10

### Filtlong filtering

**generic setting for keeping 90% of the reads:**

    filtlong --min_length 1000 --keep_percent 90 nanopore_reads.fastq | gzip > nanopore_filtlong.fastq.gz

## Reads assembly

Reads assembly are using long reads as skeleton and short reads for correction. Two different software are usually used for long reads assembly: Canu or Flye, each has their own advantages.

### Canu assembly

**Canu required an estimate genome size for assembly, following command is using a 1.2 Gb as an example:**

    canu -p canu -genomeSize=1.2g -nanopore-raw reads.fastq

### Flye assembly

**Flye required an estimate genome size for assembly, following command is using a 1.2 Gb as an example:**

    flye --nano-raw nanopore.fastq.gz --threads 30 --out-dir ./ --genome-size 1.2g

## Contigs/scaffolds polish

The assembled contigs/scaffolds need to be farther polish for consensus (using Racon), reads correction (Illumina short reads mapping and correction using Pilon) and curating heterozygous (using Purge Haplotigs *optional)

### Racon consensus

**Racon can correct the assembly process that do not have consensus steps. This usually take 2 round Racon for better result. This example using a -m (score for matching bases) 3 and -x (score for mismatching bases) -5. Racon also required overlaps mapping which can be acquired using bwa.**

    bwa index assembled.fasta
    bwa mem -t 16 -x ont2d assembled.fasta nanopore.fastq > mapping.sam
    racon -m 8 -x -6 -t 16 nanopore.fastq mapping.sam assembled.fasta > racon.fasta
    bwa index racon.fasta
    bwa mem -t 14 -x ont2d racon.fasta nanopore.fastq > mapping2nd.sam
    racon -m 8 -x -6 -t 16 nanopore.fastq mapping2nd.sam racon.fasta > racon2nd.fasta

### Pilon polishing

**Pilon can be used for improving draft assemblies. Personally, I use 2 round Pilon for assembly polishing. Pilon also required mapping information using illumine short reads which can be acquired using bwa.**

    bwa index racon2nd.fasta
    bwa mem -t 16 racon2nd.fasta reads_R1.fastq reads_R2.fastq | samtools view - -Sb | samtools sort - -@14 -o mapping.sorted.bam
    samtools index mapping.sorted.bam
    java -Xmx32G -jar pilon-1.23.jar --genome racon2nd.fasta --fix all --changes --frags mapping.sorted.bam --threads 16 --output ./pilon_round1 | tee ./round1.pilon
    bwa index pilon_round1.fasta
    bwa mem -t 16 pilon_round1.fasta reads_R1.fastq reads_R2.fastq | samtools view - -Sb | samtools sort - -@14 -o ./mapping_pilon1.sorted.bam
    samtools index mapping_pilon1.sorted.bam
    java -Xmx32G -jar pilon-1.23.jar --genome pilon_round1.fasta --fix all --changes --frags mapping_pilon1.sorted.bam --threads 16 --output ./pilon_round2 | tee ./round2.pilon

### Purge Haplotigs heterozygous curating for diploid genome

** Purge Haplotigs can help with curating heterozygous diploid genome assemblies. Purge Haplotigs also required mapping information using long sequencing reads by using minimap2. The purge_haplotigs contigcov need the result from purge_haplotigs readhist and using the low cutoff for -l, mid-point for -m and high cutoff for -h.**

    minimap2 -ax map-pb round2.pilon.fasta nanopore.fastq | samtools view -hF 256 - | samtools sort -@ 8 -m 1G -o aligned.bam -T tmp.ali
    purge_haplotigs readhist -b aligned.bam -g round2.pilon.fasta -t 16
    purge_haplotigs contigcov -i aligned.bam.gencov -l 10 -m 95 -h 190
    purge_haplotigs purge -g round2.pilon.fasta -c coverage_stats.csv -t 16 -r ../repeats.bed
