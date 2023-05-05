# Juicer usage

This is an instruction of Juicer usage using the reference data from Juicer.



## Juicer detailed usage:

  Usage: juicer.sh [-g genomeID] [-d topDir] [-q queue] [-l long queue] [-s site]
                 [-a about] [-R end] [-S stage] [-p chrom.sizes path]
                 [-y restriction site file] [-z reference genome file]
                 [-C chunk size] [-D Juicer scripts directory]
                 [-Q queue time limit] [-L long queue time limit] [-e] [-h] [-x]
  * [genomeID] must be defined in the script, e.g. "hg19" or "mm10" (default
  "hg19"); alternatively, it can be defined using the -z command
  * [topDir] is the top level directory (default
  "/Users/nchernia/Downloads/neva-muck/UGER")
     [topDir]/fastq must contain the fastq files
     [topDir]/splits will be created to contain the temporary split files
     [topDir]/aligned will be created for the final alignment
  * [queue] is the queue for running alignments (default "short")
  * [long queue] is the queue for running longer jobs such as the hic file
  creation (default "long")
  * [site] must be defined in the script, e.g.  "HindIII" or "MboI"
  (default "none")
  * [about]: enter description of experiment, enclosed in single quotes
  * [stage]: must be one of "chimeric", "merge", "dedup", "final", "postproc", or "early".
    -Use "chimeric" when alignments are done but chimeric handling has not finished
    -Use "merge" when alignment has finished but the merged_sort file has not
     yet been created.
    -Use "dedup" when the files have been merged into merged_sort but
     merged_nodups has not yet been created.
    -Use "final" when the reads have been deduped into merged_nodups but the
     final stats and hic files have not yet been created.
    -Use "postproc" when the hic files have been created and only
     postprocessing feature annotation remains to be completed.
    -Use "early" for an early exit, before the final creation of the stats and
     hic files
  * [chrom.sizes path]: enter path for chrom.sizes file
  * [restriction site file]: enter path for restriction site file (locations of
  restriction sites in genome; can be generated with the script
  (misc/generate_site_positions.py) )
  * [reference genome file]: enter path for reference sequence file, BWA index
  files must be in same directory
  * [chunk size]: number of lines in split files, must be multiple of 4
  (default 90000000, which equals 22.5 million reads)
  * [Juicer scripts directory]: set the Juicer directory,
  which should have scripts/ references/ and restriction_sites/ underneath it
  (default /broad/aidenlab)
  * [queue time limit]: time limit for queue, i.e. -W 12:00 is 12 hours
  (default 1200)
  * [long queue time limit]: time limit for long queue, i.e. -W 168:00 is one week
  (default 3600)
  * -f: include fragment-delimited maps from hic file creation
  * -e: early exit
  * -h: print this help and exit


## Running Juicer with correct folder path:

    ~/opt/juicer/scripts/juicer.sh \
    -z ~/opt/juicer/references/Homo_sapiens_assembly19.fasta #reference genome\
    -p ~/opt/juicer/restriction_sites/hg19.chrom.sizes #chromosome size \
    -y ~/opt/juicer/restriction_sites/hg19_MboI.txt #restriction_sites\
    -d ~/rawdata/A549/replicate1 #hi-c data\
    -D ~/juicer_data #working directory