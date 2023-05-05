# Classify metagenome using Krona

This is a prototype for classify the taxonomy of the metagenome sequencing

## Assembly the genome

    conda create –name juicer
    conda activate juicer

## Installation of Krona

1) Krona download and installation
    cd ~/opt
    wget https://github.com/marbl/Krona/archive/refs/tags/v2.8.tar.gz
    tar -xzvf v2.8.tar.gz
    cd Krona-2.8/KronaTools/
    ./install.pl --prefix /<your full path to your home folder>/opt/

2) Download/update the latest NCBI taxonomy database
    ./updateTaxonomy.sh

## Installation and setup the diamond taxonomy blast

1) install diamond in the new environment (some software may influence the new version of diamond blast to be installed)

    conda create -n diamond -c bioconda diamond
	
2) Download and build the latest NCBI NR database for diamond

    wget ftp://ftp.ncbi.nlm.nih.gov/blast/db/FASTA/nr.gz
    wget ftp://ftp.ncbi.nlm.nih.gov/blast/db/FASTA/nr.gz

2) Download/update the latest NCBI taxonomy database
    ./updateTaxonomy.sh

### Blow is just an example for Juicer data format, please see the Juicer build below

    mkdir references
    cp <my_reference_fastas_and_indices> references/
	
    # this is optional, only needed for fragment-delimited files
	
    ln -s <myRestrictionSiteDir> restriction_sites
    cd <myWorkingDir>
    mkdir fastq
    mv <fastq_files> fastq/
    ~/opt/Juicer/scripts/juicer.sh -D <myJuicerDir>

## Installation the dependencies for Juicer:

1) GNU CoreUtils
    conda install -c conda-forge coreutils
2) Burrows-Wheeler Aligner (BWA)
    conda install -c bioconda bwa

## Build the Juicer using reference data

1) Make the reference folder
    mkdir juicer_data
    cd juicer_data
    mkdir references; cd references
    wget https://s3.amazonaws.com/juicerawsmirror/opt/juicer/references/Homo_sapiens_assembly19.fasta
    wget https://s3.amazonaws.com/juicerawsmirror/opt/juicer/references/Homo_sapiens_assembly19.fasta.amb
    wget https://s3.amazonaws.com/juicerawsmirror/opt/juicer/references/Homo_sapiens_assembly19.fasta.ann
    wget https://s3.amazonaws.com/juicerawsmirror/opt/juicer/references/Homo_sapiens_assembly19.fasta.bwt
    wget https://s3.amazonaws.com/juicerawsmirror/opt/juicer/references/Homo_sapiens_assembly19.fasta.pac
    wget https://s3.amazonaws.com/juicerawsmirror/opt/juicer/references/Homo_sapiens_assembly19.fasta.sa
    cd ..

2) Build the restriction site folder
    mkdir restriction_sites; cd restriction_sites
    wget https://s3.amazonaws.com/juicerawsmirror/opt/juicer/restriction_sites/hg19_MboI.txt
    awk 'BEGIN{OFS="\t"}{print $1, $NF}' hg19_MboI.txt > hg19.chrom.sizes
    cd ..

3) Build the dataset from Hi-C
    mkdir HIC003; cd HIC003
    mkdir fastq; cd fastq
    wget http://juicerawsmirror.s3.amazonaws.com/opt/juicer/work/HIC003/fastq/HIC003_S2_L001_R1_001.fastq.gz
    wget http://juicerawsmirror.s3.amazonaws.com/opt/juicer/work/HIC003/fastq/HIC003_S2_L001_R2_001.fastq.gz
    cd ..
