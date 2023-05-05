# Gene Family Expansion and Contraction Pipeline

This pipeline is a prototype of get gene family expansion and contraction using cafe5

## Software prerequisites

1) Othofinder
2) Cafe
3) r8s
4) seqkit
5) raxml

## Data/resources

1) protein sequences of different species (fasta file)
2) Reference genome (fasta file)
3) Barcodes ID for GBS sequence (txt file)
4) Population map for all dataset (txt file)

## Installation

Install all required software via conda:

    conda create -n cafe -c bioconda orthofinder
	conda activate cafe
    conda install -c bioconda cafe
    conda install -c bioconda seqkit -y
	conda install -c bioconda raxml
	conda install -c bioconda raxml-ng

Install r8s seperartely:

	wget -q https://sourceforge.net/projects/r8s/files/r8s1.81.tar.gz \
	&& tar -zxvf r8s1.81.tar.gz \
	&& cd r8s1.81/src \
	&& cp Makefile.linux Makefile.linux.bak \
	&& sed -i 's/continuousML.o //' Makefile.linux \
	&& sed -i 's/continuousML.o:/#continuousML.o:/' Makefile.linux \
	&& make -f Makefile.linux

## Gene family identification

The Orthofinder needs the protein seuqences of all the species you want to compare without isoform(s)

### Orthofinder usage
   
    orthofinder -f ./ -S diamond -M msa -T raxml-ng -t 20 -a 8
	-S diamond	Sequence search program [Default = diamond] use diamond for the speed
	-M msa		Method for gene tree inference. Options 'dendroblast' & 'msa' [Default = dendroblast]
	-T raxml-ng	Tree inference method, requires '-M msa' [Default = fasttree]
	-t 20 		Number of parallel sequence search threads [Default = 12]
	-a 8		Number of parallel analysis threads [Default = 1]
	
## r8s ultrametric tree

The r8s ultrametric trees (sometimes also called “dendrograms”) are a special kind of additive tree in which the tips of the trees are all equidistant from the root of the tree. This kind of tree can be used to depict evolutionary time, expressed either directly as years or indirectly as amount of sequence divergence using a molecular clock.    

### Prepare the calibration species for R8S to use

1. Put two calibration species name in http://timetree.org/
2. Get the molecular time estimates for the calibration species

### Prepare the input file for r8s

The input file is from the result of Orthofinder: Species_Tree/SpeciesTree_rooted.txt

	#### seqkit to get the number of gene family 
	seqkit stat MultipleSequenceAlignments/SpeciesTreeAlignment.fa 
	file                                                format  type     num_seqs     sum_len    min_len    avg_len    max_len
	MultipleSequenceAlignments/SpeciesTreeAlignment.fa  FASTA   Protein        14  31,629,122  2,259,223  2,259,223  2,259,223
	#### check the parameter of the script
	python ../01.script/cafetutorial_prep_r8s.py --help
	#######################==parameter==###############################################################################
	optional arguments:
		-h, --help            show this help message and exit
		-i INPUT_FILE, --input-file INPUT_FILE
				full path to .txt file containing tree in NEWICK format			## input tree file should be NEWICK format
		-o OUTPUT_FILE, --output-file OUTPUT_FILE
				full path to file to be written (r8s input file)				## output file location
		-s SITES_N, --sites-n SITES_N
				number of sites in alignment used to estimate species tree		## the number of gene family
		-p SPP_PAIRS, --pairs-species SPP_PAIRS									## name of calibration species same as your protein file
		-c CAL_POINTS, --calibration-points CAL_POINTS							## calibration point（MYA）
	#######################==parameter==###############################################################################
	#### use python version 2 to run the python script，calibration species name should be the same of the protein files
	python2 cafetutorial_prep_r8s.py -i SpeciesTree_rooted.txt -o ./r8s_ctl_file.txt -s 1359876 -p Astrothelium_macrocarpum,Arthonia_radiata_GCA_002989075.1' -c '307'
	#### check the r8s config file
	cat r8s_ctl_file.txt
	#######################==r8s-config-file==###############################################################################
	#NEXUS
	begin trees;
	tree nj_tree = [&R] <This is the tree file>
	End;
	begin rates;
	blformat nsites=1359876 lengths=persite ultrametric=no;							# put the nsites into here
	collapse;
	mrca pum5.1 Astrothelium_macrocarpum Arthonia_radiata_GCA_002989075.1;			# calibration species
	fixage taxon=pum5.1 age=307;													# pum5.1 is the last three word of the two calibration species
	divtime method=pl algorithm=tn cvStart=0 cvInc=0.5 cvNum=8 crossv=yes;
	describe plot=chronogram;
	describe plot=tree_description;
	#######################==r8s-config-file==###############################################################################

### r8s calculate ultrametric tree

    #### run r8s
	~/opt/r8s1.81/src/r8s -b -f r8s_ctl_file.txt >r8s_tmp.txt
	#### extract the useful data from the r8s output
	tail -n 1 r8s_tmp.txt | cut -c 16- > r8s_ultrametric.txt

## Run CAFE5

Optinal using coordinate sorted bam file with readgroups added to the BAM header.

### Sort the bam files and add readgroups (required samtools and picard)

The Cafe tab format requirs additional information for the format

    ##===================Cafe reuired format===================##
	Desc   sp-A      sp-B sp-C sp-D sp-E sp-F     sp-G sp-H sp-I sp-J sp-K     sp-L  sp-M 
	(null)  OG0000000       3       37      12      24      39      51      31      4       3       73      95      15      62      69
	(null)  OG0000001       8       23      21      27      32      42      1       26      30      19      48      5       34      36
	(null)  OG0000002       18      21      15      19      23      29      6       27      30      22      24      37      26      42
	##===================Cafe reuired format===================##

The orignal outpur from Orthofinder

    ##===================Orthogroups.GeneCount.tsv===================##
	Orthogroup       sp-A      sp-B sp-C sp-D sp-E sp-F     sp-G sp-H sp-I sp-J sp-K     sp-L  sp-M Total
	OG0000000       3       37      12      24      39      51      31      4       3       73      95      15      62      69      518
	OG0000001       8       23      21      27      32      42      1       26      30      19      48      5       34      36      352
	OG0000002       18      21      15      19      23      29      6       27      30      22      24      37      26      42      339
	##===================Orthogroups.GeneCount.tsv===================##

### change the format of the Orthofinder output

    awk 'OFS="\t" {$NF=""; print}' Orthogroups.GeneCount.tsv > tmp && awk '{print "(null)""\t"$0}' tmp > cafe.input.tsv && sed -i '1s/(null)/Desc/g' cafe.input.tsv && rm tmp

### Filter the tab file from the Orthofinder

Filter the gene families with gene copies in at least two species of the specified clades.

    python cafetutorial_clade_and_size_filter.py -i cafe.input.tsv -o filtered.cafe.input.tsv -s 2> filtered.log

### Run the CAFE5

    cafe5 -i filtered.cafe.input.tsv -t r8s_ultrametric.txt -p -k 2 -o test2

