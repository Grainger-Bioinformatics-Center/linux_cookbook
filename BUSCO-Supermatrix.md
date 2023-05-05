# BUSCO to Phylogeny Pipeline

This pipeline is modified from by Magnus Wolf 2021 (magnus.wolf@senckenberg.de).  It can be used to running BUSCO program and generate the supermatrix/supertree automatically.

## Installation

This pipeline can be easily installed from conda and use via simple configuration

### Downloading the main pipeline

    wget https://github.com/mag-wolf/BUSCO-to-Phylogeny/blob/main/BUSCO-to-Phylogeny.tar.gz
    tar BUSCO-to-Phylogeny.tar.gz BUSCO-to-Phylogeny
    cd BUSCO-to-Phylogeny
	unzip *.zip

### Install all the dependency via different conda enviroment

    conda create --name MAFFTenv
    conda install -n MAFFTenv -c bioconda mafft
    conda create --name CLIPKITenv
    conda install -n CLIPKITenv -c jlsteenwyk clipkit
    conda create --name IQTREEenv
    conda install -n IQTREEenv -c bioconda iqtree
    conda create --name BUSCOenv
    conda install -n BUSCOenv -c bioconda -c conda-forge busco =5.3.2

## Configuration

1.) Gather whole genome assemblies in fasta format for all species you want to have in your tree. Copy them to the work directory and rename as the species name accordingly.

2.) Open the script BUSCO-to-Phylogeny.sh with a text editor and change the dependencies and working directory as you have. Make sure the conda environment are correct.

3.) Edit BUSCO-to-Phylogeny dependencies and parameters. Especially the OrthoDB database for BUSCO and the augustus training species you want to use.

4.) Edit options for BUSCO-to-PHYLOGENY. Call everything "TRUE" that you want to use. The pipeline contains 10 subparts that can be run independently if all other subparts are called "FALSE". By leaving it as it is, everything will run one by one.

5.) Delete the config.ini in your working directory unless you want to set the BUSCO by yourself.

6.) Now simply run:
Reads assembly are using long reads as skeleton and short reads for correction.

    bash BUSCO-to-Phylogeny.sh 2>&1 | tee error.log

## List of all subparts for pipeline and canbe run individually

    runbusco                   #run the BUSCO tool on every assembly for annotation and getting single copy orthologs.
    findsharedscos             #find BUSCO genes that are shared between all of the species you provided
    makealignments             #make alignments of all gene sequences using mafft
    trimmgenealignments        #trimm the alignments using clipkit
    filteralignments           #filter the alignments for to conserved genes
    concatgenealignments       #concatenate gene alignments into one big matrix using FASconCAT
    trimmsupermatrix           #trimm the concatenated alignment using clipkit
    constructgenetrees         #constructing gene trees of every single gene alignment using iqtree
    constructsupermtree        #constructing a tree from the concatenated alignment using iqtree
    constructsuperttree        #constructing a consensus tree based on all constructed genes trees using Astral

## Other BUSCO to Phylogeny method

	BuscoOrthoPhylo		https://github.com/PlantDr430/BuscoOrthoPhylo
	BUSCOfilter			https://github.com/Rowena-h/BUSCOfilter
	BUSCO_Phylogenomics	https://github.com/jamiemcg/BUSCO_phylogenomics
	busco_tree			https://github.com/zengxiaofei/busco-tree
	busco2phylo-nf		https://github.com/lstevens17/busco2phylo-nf