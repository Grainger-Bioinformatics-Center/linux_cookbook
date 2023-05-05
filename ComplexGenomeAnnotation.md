# Complex Genome Annotation Pipeline

This pipeline is a prototype of complex genome annotation using maker and other softerware.

## Software prerequisites

1) RepeatModeler and RepeatMasker with RepBase in optional
2) Maker
3) Augustus
4) BUSCO
5) SNAP
6) BEDtools

## Data/resources

1) Genome assembled contings (fasta file)
2) A de novo transcriptome assembly created using Trinity with mRNAseq data
3) Amino acid protein sequence from reference on NCBI
4) Optional repeat library

## Gene prediction

Prediction use mainly maker with Augustus SNAP as reference.

### Reorder contigs （optional）

**reorder and rename contigs by size:**
   
    seqkit sort --by-length --reverse contigs.fasta | seqkit replace --pattern '.+' --replacement 'Contig_{nr}' --nr-width 3
	
### Clean and sort contigs using funannotate （optional）

    funannotate clean -i contigs.fasta -o contigs_clean.fasta
	funannotate sort -i contigs_clean.fasta -o contigs_sorted.fasta
	
## Initial run of maker

This is using the annotated repeat, known or trusted protein database and RNA evidence to run the maker for the first time

### Using the RepBase database for the repeat annotation

    mkdir repbase_mask
	RepeatMasker -pa 20 -e ncbi -species lamiales -dir repbase_mask pedicularis_sorted.fasta
	ProcessRepeats -species lamiales pedicularis_sorted.fasta.cat.gz

### Process the RepeatMasker, isolate the complex repeats and reformat the gff file for maker use

    rmOutToGFF3.pl pedicularis_sorted.fasta.out > pedicularis.full_mask.out.gff3
	grep -v -e "Satellite" -e ")n" -e "-rich" pedicularis.full_mask.out.gff3 > pedicularis.full_mask.complex.gff3
	cat pedicularis.full_mask.complex.gff3 | perl -ane '$id; if(!/^\#/){@F = split(/\t/, $_); chomp $F[-1];$id++; $F[-1] .= "\;ID=$id"; $_ = join("\t", @F)."\n"} print $_' > pedicularis.full_mask.complex.reformat.gff3

### De Novo Repeat Identification (only for no RepBase database)

Repeat annotation using RepeatModeler

    BuildDatabase -name pelargonium -engine ncbi pelargonium_citronellum.fasta
    RepeatModeler -pa 8 -engine ncbi -database pelargonium 2>&1 | tee repeatmodeler.log

### Run maker 1st run

 1.  Edit maker_opts.ctl file with following settings
     
    #-----Genome (these are always required)
    genome=./pedicularis_sorted.fasta #genome sequence (fasta file or fasta embeded in GFF3 file)
    organism_type=eukaryotic #eukaryotic or prokaryotic. Default is eukaryotic
    
    #-----Re-annotation Using MAKER Derived GFF3
    maker_gff= #MAKER derived GFF3 file
    est_pass=0 #use ESTs in maker_gff: 1 = yes, 0 = no
    altest_pass=0 #use alternate organism ESTs in maker_gff: 1 = yes, 0 = no
    protein_pass=0 #use protein alignments in maker_gff: 1 = yes, 0 = no
    rm_pass=0 #use repeats in maker_gff: 1 = yes, 0 = no
    model_pass=0 #use gene models in maker_gff: 1 = yes, 0 = no
    pred_pass=0 #use ab-initio predictions in maker_gff: 1 = yes, 0 = no
    other_pass=0 #passthrough anyything else in maker_gff: 1 = yes, 0 = no
    
    #-----EST Evidence (for best results provide a file for at least one)
    est=./116.BFcav1_FLleaf.fasta #set of ESTs or assembled mRNA-seq in fasta format
    altest= #EST/cDNA sequence file in fasta format from an alternate organism
    est_gff= #aligned ESTs or mRNA-seq from an external GFF3 file
    altest_gff= #aligned ESTs from a closly relate species in GFF3 format
    
    #-----Protein Homology Evidence (for best results provide a file for at least one)
    protein=/home/FM/ysun/projects/Pedicularis/maker/with_NCBI/all.faa  #protein sequence file in fasta format (i.e. from mutiple organisms)
    protein_gff=  #aligned protein homology evidence from an external GFF3 file
    
    #-----Repeat Masking (leave values blank to skip repeat masking)
    model_org=all #select a model organism for RepBase masking in RepeatMasker
    rmlib= #provide an organism specific repeat library in fasta format for RepeatMasker
    repeat_protein=/home/FM/ysun/opt/maker/data/te_proteins.fasta #provide a fasta file of transposable element proteins for RepeatRunner
    rm_gff=../pedicularis.full_mask.complex.reformat.gff3 #pre-identified repeat elements from an external GFF3 file
    prok_rm=0 #forces MAKER to repeatmask prokaryotes (no reason to change this), 1 = yes, 0 = no
    softmask=1 #use soft-masking rather than hard-masking in BLAST (i.e. seg and dust filtering)
    
    #-----Gene Prediction
    snaphmm= #SNAP HMM file
    gmhmm= #GeneMark HMM file
    augustus_species=aspergillus_nidulans #Augustus gene prediction species model
    fgenesh_par_file= #FGENESH parameter file
    pred_gff= #ab-initio predictions from an external GFF3 file
    model_gff= #annotated gene models from an external GFF3 file (annotation pass-through)
    run_evm=0 #run EvidenceModeler, 1 = yes, 0 = no
    est2genome=0 #infer gene predictions directly from ESTs, 1 = yes, 0 = no
    protein2genome=0 #infer predictions from protein homology, 1 = yes, 0 = no
    trna=0 #find tRNAs with tRNAscan, 1 = yes, 0 = no
    snoscan_rrna= #rRNA file to have Snoscan find snoRNAs
    snoscan_meth= #-O-methylation site fileto have Snoscan find snoRNAs
    unmask=0 #also run ab-initio prediction programs on unmasked sequence, 1 = yes, 0 = no
    
    #-----Other Annotation Feature Types (features MAKER doesn't recognize)
    other_gff= #extra features to pass-through to final MAKER generated GFF3 file
    
    #-----External Application Behavior Options
    alt_peptide=C #amino acid used to replace non-standard amino acids in BLAST databases
    cpus=30 #max number of cpus to use in BLAST and RepeatMasker (not for MPI, leave 1 when using MPI)
    
    #-----MAKER Behavior Options
    max_dna_len=100000 #length for dividing up contigs into chunks (increases/decreases memory usage)
    min_contig=1 #skip genome contigs below this length (under 10kb are often useless)
    
    pred_flank=200 #flank for extending evidence clusters sent to gene predictors
    pred_stats=0 #report AED and QI statistics for all predictions as well as models
    AED_threshold=1 #Maximum Annotation Edit Distance allowed (bound by 0 and 1)
    min_protein=0 #require at least this many amino acids in predicted proteins
    alt_splice=1 #Take extra steps to try and find alternative splicing, 1 = yes, 0 = no
    always_complete=0 #extra steps to force start and stop codons, 1 = yes, 0 = no
    map_forward=0 #map names and attributes forward from old GFF3 genes, 1 = yes, 0 = no
    keep_preds=0 #Concordance threshold to add unsupported gene prediction (bound by 0 and 1)
    
    split_hit=10000 #length for the splitting of hits (expected max intron size for evidence alignments)
    min_intron=20 #minimum intron length (used for alignment polishing)
    single_exon=0 #consider single exon EST evidence when generating annotations, 1 = yes, 0 = no
    single_length=250 #min length required for single exon ESTs if 'single_exon is enabled'
    correct_est_fusion=0 #limits use of ESTs in annotation to avoid fusion genes
    
    tries=2 #number of times to try a contig if there is a failure for some reason
    clean_try=0 #remove all data from previous run before retrying, 1 = yes, 0 = no
    clean_up=0 #removes theVoid directory with individual analysis files, 1 = yes, 0 = no
    TMP= #specify a directory other than the system default temporary directory for temporary files

    
 2.  Edit maker_opts.ctl file (put the location of executables. For example:)

    makeblastdb=/home/FM/xxx/anaconda3/bin/makeblastdb			
    blastn=/home/FM/xxx/anaconda3/bin/blastn
    blastx=/home/FM/xxx/anaconda3/bin/blastx
    RepeatMasker=/home/FM/xxx/opt/RepeatMasker/RepeatMasker
    snap=/home/FM/xxx/anaconda3/envs/maker/bin/snap
    augustus=/home/FM/xxx/opt/Augustus/bin/augustus
	
3. Run maker `~/opt/maker/bin/maker` （optional with multiple cores: mpiexec -n 12 maker -base pedicularis_rnd1 round1_maker_opts.ctl maker_bopts.ctl maker_exe.ctl）
   
    bash ./round1_run_maker.sh 2>&1 | tee round1_run_maker.log

### Extract the output from the maker result

    cd pedicularis_sorted.maker.output
    ~/opt/maker/bin/gff3_merge -s -d pedicularis_sorted_master_datastore_index.log > pedicularis_rnd1.all.maker.gff
    ~/opt/maker/bin/fasta_merge -d pedicularis_sorted_master_datastore_index.log
    # Get the GFF without the sequences
    ~/opt/maker/bin/gff3_merge -n -s -d pedicularis_sorted_master_datastore_index.log > pedicularis_rnd1.all.maker.noseq.gff
	
### Extract the transcript, protein ,and repeat from the first round maker result

    cd pedicularis_sorted.maker.output_rnd1
    # transcript
    awk '{ if ($2 == "est2genome") print $0 }' pedicularis_rnd1.all.maker.noseq.gff > pedicularis_rnd1.all.maker.est2genome.gff
    # protein
    awk '{ if ($2 == "protein2genome") print $0 }' pedicularis_rnd1.all.maker.noseq.gff > pedicularis_rnd1.all.maker.protein2genome.gff
    # repeat
    awk '{ if ($2 ~ "repeat") print $0 }' pedicularis_rnd1.all.maker.noseq.gff > pedicularis_rnd1.all.maker.repeats.gff

## Second run for maker

This is using the result from the first round of maker to tranning the SANP and Augustus and then use the trained database from them plus the result from the 1st round maker to continue the annotation with maker

### Training SNAP

    mkdir snap
    mkdir snap/round1
    cd snap/round1
    ~/opt/maker/bin/maker2zff -x 0.25 -l 50 -d /home/FM/ysun/projects/Pedicularis/maker/116.BFcav1_FLleaf/pedicularis_sorted.maker.output/pedicularis_sorted_master_datastore_index.log
    rename 's/genome/pedicularis_rnd1.zff.length50_aed0.25/g' *
    fathom pedicularis_rnd1.zff.length50_aed0.25.ann pedicularis_rnd1.zff.length50_aed0.25.dna -gene-stats > gene-stats.log 2>&1
    fathom pedicularis_rnd1.zff.length50_aed0.25.ann pedicularis_rnd1.zff.length50_aed0.25.dna -validate > validate.log 2>&1
    fathom pedicularis_rnd1.zff.length50_aed0.25.ann pedicularis_rnd1.zff.length50_aed0.25.dna -categorize 1000 > categorize.log 2>&1
    fathom uni.ann uni.dna -export 1000 -plus > uni-plus.log 2>&1
    mkdir params
    cd params
    forge ../export.ann ../export.dna > ../forge.log 2>&1
    cd ../
    hmm-assembler.pl pelargonium_rnd1.zff.length50_aed0.25 params > pelargonium_rnd1.zff.length50_aed0.25.hmm

### Training Augustus with BUSCO
“Using the BUSCO v5.3.0 for the trainning”

    cd pedicularis_sorted.maker.output
	~/opt/maker/bin/gff3_merge -s -d pedicularis_sorted_master_datastore_index.log > pedicularis_rnd1.all.maker.gff
	~/opt/maker/bin/fasta_merge -d pedicularis_sorted_master_datastore_index.log
	~/opt/maker/bin/gff3_merge -n -s -d pedicularis_sorted_master_datastore_index.log > pedicularis_rnd1.all.maker.noseq.gff
	cd ..
	samtools index pedicularis_sorted.fasta
	mkdir augustus
	mkdir augustus/round1
	awk -v OFS="\t" '{print $1, $4, $5 }' ../../pedicularis_sorted.maker.output/pedicularis_rnd1.all.maker.noseq.gff | awk -v OFS="\t" '{ if ($2 < 1000) print $1, "0", $3+1000; else print $1, $2-1000, $3+1000 }' | bedtools getfasta -fi ../../pedicularis_sorted.fasta -bed - -fo pedicularis_rnd1.all.maker.transcripts1000.fasta
	seqkit rmdup -s <pedicularis_rnd1.all.maker.transcripts1000.fasta> pedicularis_rnd1.all.maker.transcripts1000_du.fasta
	busco -i pedicularis_rnd1.all.maker.transcripts1000_du.fasta -o pedicularis_rnd1_maker -l eudicots_odb10 -m genome -c 8 --long --augustus_species arabidopsis --augustus_parameters='--progress=true' -f
	cd /home/FM/xxx/projects/Pedicularis/maker/116.BFcav1_FLleaf/augustus/round1/pedicularis_rnd1_maker/run_eudicots_odb10/augustus_output/retraining_parameters/BUSCO_pedicularis_rnd1_maker/
	rename 's/BUSCO_pedicularis_rnd1_maker/pedicularis/g' *
	sed -i 's/BUSCO_pedicularis_rnd1_maker/pedicularis/g' pedicularis_parameters.cfg
	sed -i 's/BUSCO_pedicularis_rnd1_maker/pedicularis/g' pedicularis_parameters.cfg.orig1
	mkdir /home/FM/xxx/anaconda3/envs/maker/config/species/pedicularis
	cp pedicularis* /home/FM/xxx/anaconda3/envs/maker/config/species/pedicularis

### Maker 2nd run

 1.  Edit maker_opts.ctl file with following settings
     
    #-----Genome (these are always required)
    genome=./pedicularis_sorted.fasta #genome sequence (fasta file or fasta embeded in GFF3 file)
    organism_type=eukaryotic #eukaryotic or prokaryotic. Default is eukaryotic
    
    #-----Re-annotation Using MAKER Derived GFF3
    maker_gff= #MAKER derived GFF3 file
    est_pass=0 #use ESTs in maker_gff: 1 = yes, 0 = no
    altest_pass=0 #use alternate organism ESTs in maker_gff: 1 = yes, 0 = no
    protein_pass=0 #use protein alignments in maker_gff: 1 = yes, 0 = no
    rm_pass=0 #use repeats in maker_gff: 1 = yes, 0 = no
    model_pass=0 #use gene models in maker_gff: 1 = yes, 0 = no
    pred_pass=0 #use ab-initio predictions in maker_gff: 1 = yes, 0 = no
    other_pass=0 #passthrough anyything else in maker_gff: 1 = yes, 0 = no
    
    #-----EST Evidence (for best results provide a file for at least one)
    est= #set of ESTs or assembled mRNA-seq in fasta format
    altest= #EST/cDNA sequence file in fasta format from an alternate organism
    est_gff= pelargonium_rnd1.maker.output/pelargonium_rnd1.all.maker.est2genome.gff#aligned ESTs or mRNA-seq from an external GFF3 file
    altest_gff= #aligned ESTs from a closly relate species in GFF3 format
    
    #-----Protein Homology Evidence (for best results provide a file for at least one)
    protein=  #protein sequence file in fasta format (i.e. from mutiple organisms)
    protein_gff= pelargonium_rnd1.maker.output/pelargonium_rnd1.all.maker.protein2genome.gff #aligned protein homology evidence from an external GFF3 file
    
    #-----Repeat Masking (leave values blank to skip repeat masking)
    model_org=all #select a model organism for RepBase masking in RepeatMasker
    rmlib= #provide an organism specific repeat library in fasta format for RepeatMasker
    repeat_protein #provide a fasta file of transposable element proteins for RepeatRunner
    rm_gff= pelargonium_rnd1.maker.output/pelargonium_rnd1.all.maker.repeats.gff #pre-identified repeat elements from an external GFF3 file
    prok_rm=0 #forces MAKER to repeatmask prokaryotes (no reason to change this), 1 = yes, 0 = no
    softmask=1 #use soft-masking rather than hard-masking in BLAST (i.e. seg and dust filtering)
    
    #-----Gene Prediction
    snaphmm= snap/round1/pelargonium_rnd1.zff.length50_aed0.25.hmm #SNAP HMM file
    gmhmm= #GeneMark HMM file
    augustus_species= pelargonium #Augustus gene prediction species model
    fgenesh_par_file= #FGENESH parameter file
    pred_gff= #ab-initio predictions from an external GFF3 file
    model_gff= #annotated gene models from an external GFF3 file (annotation pass-through)
    run_evm=1 #run EvidenceModeler, 1 = yes, 0 = no
    est2genome=1 #infer gene predictions directly from ESTs, 1 = yes, 0 = no
    protein2genome=1 #infer predictions from protein homology, 1 = yes, 0 = no
    trna=1 #find tRNAs with tRNAscan, 1 = yes, 0 = no
    snoscan_rrna= #rRNA file to have Snoscan find snoRNAs
    snoscan_meth= #-O-methylation site fileto have Snoscan find snoRNAs
    unmask=0 #also run ab-initio prediction programs on unmasked sequence, 1 = yes, 0 = no
    
    #-----Other Annotation Feature Types (features MAKER doesn't recognize)
    other_gff= #extra features to pass-through to final MAKER generated GFF3 file
    
    #-----External Application Behavior Options
    alt_peptide=C #amino acid used to replace non-standard amino acids in BLAST databases
    cpus=20 #max number of cpus to use in BLAST and RepeatMasker (not for MPI, leave 1 when using MPI)
    
    #-----MAKER Behavior Options
    max_dna_len= 300000 #length for dividing up contigs into chunks (increases/decreases memory usage)
    min_contig=1 #skip genome contigs below this length (under 10kb are often useless)
    
    pred_flank=200 #flank for extending evidence clusters sent to gene predictors
    pred_stats=0 #report AED and QI statistics for all predictions as well as models
    AED_threshold=1 #Maximum Annotation Edit Distance allowed (bound by 0 and 1)
    min_protein=0 #require at least this many amino acids in predicted proteins
    alt_splice=1 #Take extra steps to try and find alternative splicing, 1 = yes, 0 = no
    always_complete=0 #extra steps to force start and stop codons, 1 = yes, 0 = no
    map_forward=0 #map names and attributes forward from old GFF3 genes, 1 = yes, 0 = no
    keep_preds=0 #Concordance threshold to add unsupported gene prediction (bound by 0 and 1)
    
    split_hit=20000 #length for the splitting of hits (expected max intron size for evidence alignments)
    min_intron=20 #minimum intron length (used for alignment polishing)
    single_exon=0 #consider single exon EST evidence when generating annotations, 1 = yes, 0 = no
    single_length=250 #min length required for single exon ESTs if 'single_exon is enabled'
    correct_est_fusion=0 #limits use of ESTs in annotation to avoid fusion genes
    
    tries=2 #number of times to try a contig if there is a failure for some reason
    clean_try=0 #remove all data from previous run before retrying, 1 = yes, 0 = no
    clean_up=0 #removes theVoid directory with individual analysis files, 1 = yes, 0 = no
    TMP= #specify a directory other than the system default temporary directory for temporary files
    
 2.  run maker

### Run Maker 3rd run with retrained SNAP and Augustus using the same procedure

### Extract the output from the maker round2 result
    
    cd pedicularis_sorted.maker.output
    ~/opt/maker/bin/gff3_merge -s -d pedicularis_sorted_master_datastore_index.log > pedicularis_rnd2.all.maker.gff
    ~/opt/maker/bin/fasta_merge -d pedicularis_sorted_master_datastore_index.log
    # Get the GFF without the sequences
    ~/opt/maker/bin/gff3_merge -n -s -d pedicularis_sorted_master_datastore_index.log > pedicularis_rnd2.all.maker.noseq.gff

### Extract the transcript, protein ,and repeat from the second round maker result
    
    cd pedicularis_sorted.maker.output_rnd2
    # transcript
    awk '{ if ($2 == "est2genome") print $0 }' pedicularis_rnd2.all.maker.noseq.gff > pedicularis_rnd2.all.maker.est2genome.gff
    # protein
    awk '{ if ($2 == "protein2genome") print $0 }' pedicularis_rnd2.all.maker.noseq.gff > pedicularis_rnd2.all.maker.protein2genome.gff
    # repeat
    awk '{ if ($2 ~ "repeat") print $0 }' pedicularis_rnd2.all.maker.noseq.gff > pedicularis_rnd2.all.maker.repeats.gff

## Third run for maker

This round is as the same as the 2nd round which is using all the evidence from the 2nd round for the third time maker annotation

### Training SNAP
    
    mkdir snap/round2
    cd snap/round2
    ~/opt/maker/bin/maker2zff -x 0.25 -l 50 -d /home/FM/ysun/projects/Pedicularis/maker/116.BFcav1_FLleaf/pedicularis_sorted.maker.output/pedicularis_sorted_master_datastore_index.log
    rename 's/genome/pedicularis_rnd2.zff.length50_aed0.25/g' *
    fathom pedicularis_rnd2.zff.length50_aed0.25.ann pedicularis_rnd2.zff.length50_aed0.25.dna -gene-stats > gene-stats.log 2>&1
    fathom pedicularis_rnd2.zff.length50_aed0.25.ann pedicularis_rnd2.zff.length50_aed0.25.dna -validate > validate.log 2>&1
    fathom pedicularis_rnd2.zff.length50_aed0.25.ann pedicularis_rnd2.zff.length50_aed0.25.dna -categorize 1000 > categorize.log 2>&1
    fathom uni.ann uni.dna -export 1000 -plus > uni-plus.log 2>&1
    mkdir params
    cd params
    forge ../export.ann ../export.dna > ../forge.log 2>&1
    cd ../
    hmm-assembler.pl pelargonium_rnd2.zff.length50_aed0.25 params > pelargonium_rnd2.zff.length50_aed0.25.hmm

### Training Augustus with BUSCO
“Using the BUSCO v5.3.0 for the trainning”
    
    cd pedicularis_sorted.maker.output
	~/opt/maker/bin/gff3_merge -s -d pedicularis_sorted_master_datastore_index.log > pedicularis_rnd1.all.maker.gff
	~/opt/maker/bin/fasta_merge -d pedicularis_sorted_master_datastore_index.log
	~/opt/maker/bin/gff3_merge -n -s -d pedicularis_sorted_master_datastore_index.log > pedicularis_rnd1.all.maker.noseq.gff
	cd ..
	mkdir augustus/round2
	cd augustus/round2
	awk -v OFS="\t" '{print $1, $4, $5 }' ../../pedicularis_sorted.maker.output/pedicularis_rnd2.all.maker.noseq.gff | awk -v OFS="\t" '{ if ($2 < 1000) print $1, "0", $3+1000; else print $1, $2-1000, $3+1000 }' | bedtools getfasta -fi ../../pedicularis_sorted.fasta -bed - -fo pedicularis_rnd2.all.maker.transcripts1000.fasta
	seqkit rmdup -s <pedicularis_rnd2.all.maker.transcripts1000.fasta> pedicularis_rnd2.all.maker.transcripts1000_du.fasta
	## switch to busco env
	busco -i pedicularis_rnd2.all.maker.transcripts1000_du.fasta -o pedicularis_rnd2_maker -l eudicots_odb10 -m genome -c 8 --long --augustus_species arabidopsis --augustus_parameters='--progress=true' -f
	cd /home/FM/xxx/projects/Pedicularis/maker/116.BFcav1_FLleaf/augustus/round2/pedicularis_rnd2_maker/run_eudicots_odb10/augustus_output/retraining_parameters/BUSCO_pedicularis_rnd2_maker/
	rename 's/BUSCO_pedicularis_rnd2_maker/pedicularis2/g' *
	sed -i 's/BUSCO_pedicularis_rnd2_maker/pedicularis2/g' pedicularis2_parameters.cfg
	sed -i 's/BUSCO_pedicularis_rnd2_maker/pedicularis2/g' pedicularis2_parameters.cfg.orig1
	mkdir /home/FM/xxx/anaconda3/envs/maker/config/species/pedicularis2
	cp pedicularis* /home/FM/xxx/anaconda3/envs/maker/config/species/pedicularis2

### Maker 3rd run

 1.  Edit maker_opts.ctl file with following settings
     
    #-----Genome (these are always required)
    genome=./pedicularis_sorted.fasta #genome sequence (fasta file or fasta embeded in GFF3 file)
    organism_type=eukaryotic #eukaryotic or prokaryotic. Default is eukaryotic
    
    #-----Re-annotation Using MAKER Derived GFF3
    maker_gff= #MAKER derived GFF3 file
    est_pass=0 #use ESTs in maker_gff: 1 = yes, 0 = no
    altest_pass=0 #use alternate organism ESTs in maker_gff: 1 = yes, 0 = no
    protein_pass=0 #use protein alignments in maker_gff: 1 = yes, 0 = no
    rm_pass=0 #use repeats in maker_gff: 1 = yes, 0 = no
    model_pass=0 #use gene models in maker_gff: 1 = yes, 0 = no
    pred_pass=0 #use ab-initio predictions in maker_gff: 1 = yes, 0 = no
    other_pass=0 #passthrough anyything else in maker_gff: 1 = yes, 0 = no
    
    #-----EST Evidence (for best results provide a file for at least one)
    est= #set of ESTs or assembled mRNA-seq in fasta format
    altest= #EST/cDNA sequence file in fasta format from an alternate organism
    est_gff= pelargonium_rnd2.maker.output/pelargonium_rnd2.all.maker.est2genome.gff #aligned ESTs or mRNA-seq from an external GFF3 file
    altest_gff= #aligned ESTs from a closly relate species in GFF3 format
    
    #-----Protein Homology Evidence (for best results provide a file for at least one)
    protein=  #protein sequence file in fasta format (i.e. from mutiple organisms)
    protein_gff= pelargonium_rnd2.maker.output/pelargonium_rnd2.all.maker.protein2genome.gff #aligned protein homology evidence from an external GFF3 file
    
    #-----Repeat Masking (leave values blank to skip repeat masking)
    model_org=all #select a model organism for RepBase masking in RepeatMasker
    rmlib= #provide an organism specific repeat library in fasta format for RepeatMasker
    repeat_protein #provide a fasta file of transposable element proteins for RepeatRunner
    rm_gff= pelargonium_rnd2.maker.output/pelargonium_rnd2.all.maker.repeats.gff #pre-identified repeat elements from an external GFF3 file
    prok_rm=0 #forces MAKER to repeatmask prokaryotes (no reason to change this), 1 = yes, 0 = no
    softmask=1 #use soft-masking rather than hard-masking in BLAST (i.e. seg and dust filtering)
    
    #-----Gene Prediction
    snaphmm= snap/round2/pelargonium_rnd2.zff.length50_aed0.25.hmm #SNAP HMM file
    gmhmm= #GeneMark HMM file
    augustus_species= pelargonium2 #Augustus gene prediction species model
    fgenesh_par_file= #FGENESH parameter file
    pred_gff= #ab-initio predictions from an external GFF3 file
    model_gff= #annotated gene models from an external GFF3 file (annotation pass-through)
    run_evm=0 #run EvidenceModeler, 1 = yes, 0 = no
    est2genome=0 #infer gene predictions directly from ESTs, 1 = yes, 0 = no
    protein2genome=0 #infer predictions from protein homology, 1 = yes, 0 = no
    trna=1 #find tRNAs with tRNAscan, 1 = yes, 0 = no
    snoscan_rrna= #rRNA file to have Snoscan find snoRNAs
    snoscan_meth= #-O-methylation site fileto have Snoscan find snoRNAs
    unmask=0 #also run ab-initio prediction programs on unmasked sequence, 1 = yes, 0 = no
    
    #-----Other Annotation Feature Types (features MAKER doesn't recognize)
    other_gff= #extra features to pass-through to final MAKER generated GFF3 file
    
    #-----External Application Behavior Options
    alt_peptide=C #amino acid used to replace non-standard amino acids in BLAST databases
    cpus=20 #max number of cpus to use in BLAST and RepeatMasker (not for MPI, leave 1 when using MPI)
    
    #-----MAKER Behavior Options
    max_dna_len= 300000 #length for dividing up contigs into chunks (increases/decreases memory usage)
    min_contig=1 #skip genome contigs below this length (under 10kb are often useless)
    
    pred_flank=200 #flank for extending evidence clusters sent to gene predictors
    pred_stats=0 #report AED and QI statistics for all predictions as well as models
    AED_threshold=1 #Maximum Annotation Edit Distance allowed (bound by 0 and 1)
    min_protein=0 #require at least this many amino acids in predicted proteins
    alt_splice=1 #Take extra steps to try and find alternative splicing, 1 = yes, 0 = no
    always_complete=0 #extra steps to force start and stop codons, 1 = yes, 0 = no
    map_forward=0 #map names and attributes forward from old GFF3 genes, 1 = yes, 0 = no
    keep_preds=0 #Concordance threshold to add unsupported gene prediction (bound by 0 and 1)
    
    split_hit=20000 #length for the splitting of hits (expected max intron size for evidence alignments)
    min_intron=20 #minimum intron length (used for alignment polishing)
    single_exon=0 #consider single exon EST evidence when generating annotations, 1 = yes, 0 = no
    single_length=250 #min length required for single exon ESTs if 'single_exon is enabled'
    correct_est_fusion=0 #limits use of ESTs in annotation to avoid fusion genes
    
    tries=2 #number of times to try a contig if there is a failure for some reason
    clean_try=0 #remove all data from previous run before retrying, 1 = yes, 0 = no
    clean_up=0 #removes theVoid directory with individual analysis files, 1 = yes, 0 = no
    TMP= #specify a directory other than the system default temporary directory for temporary files
    
 2.  run maker

## Check the output from each round and quality control for the annotation

After iteratively Running maker, we needs to see the improvment from each step and do the quality control for comparing all the output

 1.  Count the number of gene models and the gene lengths after each round
    
    cat <roundN.full.gff> | awk '{ if ($3 == "gene") print $0 }' | awk '{ sum += ($5 - $4) } END { print NR, sum / NR }'
    
 2.  Check for the Annotation Edit Distance (AED) distribution (95% or more of the gene models will have an AED of 0.5 or lower in the case of good assemblies) [using script from https://github.com/mscampbell/Genome_annotation/blob/master/AED_cdf_generator.pl]
    
    perl AED_cdf_generator.pl -b 0.025 <roundN.full.gff>
    
 3.  Check the busco of the genes (change the env to the busco)
    
    BUSCO.py -i <roundN.transcripts.fasta>  -o annotation_eval -l eudicots_odb10 -m transcriptome -c 8 -sp arabidopsis -z --augustus_parameters='--progress=true'
    
 4.  Visualize all the evidence using Apollo for the best way gene prediction quality control (fully manual)

## Rename the gene tags from defaut assigned by maker 

    # create naming table (there are additional options for naming beyond defaults)
    maker_map_ids --prefix IRC --justify 5 pedicularis_rnd3.all.maker.gff > pedicularis_rnd3.all.maker.name.map
    # replace names in GFF files
    map_gff_ids pedicularis_rnd3.all.maker.name.map pedicularis_rnd3.all.maker.gff
    map_gff_ids pedicularis_rnd3.all.maker.name.map pedicularis_rnd3.all.maker.noseq.gff
    # replace names in FASTA headers
    map_fasta_ids pedicularis_rnd3.all.maker.name.map pedicularis_rnd3.all.maker.transcripts.fasta
    map_fasta_ids pedicularis_rnd3.all.maker.name.map pedicularisrnd3.all.maker.proteins.fasta