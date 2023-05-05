# Lichen Genome Annotation Pipeline

This pipeline is a prototype of Lichen genome annotation.

## Gene prediction

Prediction use maker with Augustus using *Aspergillus nidulansprediction* species model

### Reorder contigs

**reorder and rename contigs by size:**
   
    seqkit sort --by-length --reverse contigs.fasta | seqkit replace --pattern '.+' --replacement 'Contig_{nr}' --nr-width 3

   
### Run maker

 1.  Edit maker_opts.ctl file
	- put `genome=your_genome_fasta_file`
	- change `organism_type=eukaryotic`
	- put `augustus_species=aspergillus_nidulans`
	
 2.  Edit maker_opts.ctl file 
	- put the location of executables. For example:
		makeblastdb=/home/FM/xxx/anaconda3/bin/makeblastdb			
		blastn=/home/FM/xxx/anaconda3/bin/blastn
		blastx=/home/FM/xxx/anaconda3/bin/blastx
		RepeatMasker=/home/FM/xxx/opt/RepeatMasker/RepeatMasker
		snap=/usr/bin/snap
		augustus=/home/FM/xxx/opt/Augustus/bin/augustus
		
3. Run maker `~/opt/maker/bin/maker`

### Extract outputs from maker

Gff file: `~/opt/maker/bin/gff3_merge -d xxx.maker.output/xxx_master_datastore_index.log`
fasta file: `~/opt/maker/bin/fasta_merge -d xxx.maker.output/xxx_master_datastore_index.log`


## Function annotation

Function annotation with InterProScan, TrEMBL and Swiss-Prot database.

### InterProScan
	
Running InterProScan with this command

    opt/interproscan-xxx/interproscan.sh -cpu 20 -i xxx.all.maker.augustus_masked.proteins.fasta -iprlookup -goterms -pa -b xxx.interpro

### Setup TrEMBL and Swiss-Prot database

 1.  Download databases 
	
    mkdir UniProt
    get_UniProt.pl -s -t -n 20 -l download.log
	
 2.  Creating tab-delimited lists of sequence in the SwissProt/UniProt databases
	 
    hash_uniprot.pl uniprot_sprot.fasta uniprot_trembl.fasta
		

### Diamond blast

1.  Blast against two database with nucl faa file 
	
        diamond blastp -d ~/UniProt/uniprot_trembl -q xxx.all.maker.augustus_masked.proteins.fasta -o xxx_trembl.m8
        diamond blastp -d ~/UniProt/uniprot_sprot -q xxx.all.maker.augustus_masked.proteins.fasta -o xxx_sprot.m8

 2.  Generating a list of all proteins queried, inncluding those with no hits against SwissProt/UniProt (customized scripts are abiliable at https://github.com/felixgrewe/linux_cookbook/tree/master/Annotation_scripts)

    perl get_queries.pl xxx.all.maker.augustus_masked.proteins.fasta
		

### Manual curation with all evidence

1.  Parsing the result of InterProScan 5 and SwissProt/UniProt searches (customized scripts are abiliable at https://github.com/felixgrewe/linux_cookbook/tree/master/Annotation_scripts)
	
        perl parse_UniProt_BLASTs.pl -q xxx.all.maker.augustus_masked.proteins.queries -sl ~/UniProt/uniprot_sprot.products.hash -sb xxx_sprot.m8 -tl ~/UniProt/uniprot_trembl.products.hash -tb xxx_trembl.m8 -ip xxx.interpro.tsv

 2.  Curating the annotations

Curating the annotations by sellect the correct product name using this command (customized scripts are abiliable at https://github.com/felixgrewe/linux_cookbook/tree/master/Annotation_scripts)

    perl curate_annotations.pl -r -i xxx.all.maker.augustus_masked.annotations


