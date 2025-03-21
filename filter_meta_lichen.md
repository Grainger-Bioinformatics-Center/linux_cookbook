# Filter Lichen Assemblies Pipeline

This pipeline filters a lichen metagenomic assembly using BlobToolKit2. It removes contigs with low coverage (< 0.1×), contigs shorter than 1000 bp, and those that are classified as contaminants (Bacteria, Viruses, or Archaeplastida). The final filtered assembly is produced by the Bash script `filter_lichen_assemblies.sh`.

> **Note:** This pipeline assumes you are using a Unix-like system (Linux/macOS) with basic command-line experience.

## Prerequisites

### 1. Install Conda

It is recommended to use [Miniconda](https://docs.conda.io/en/latest/miniconda.html) or [Anaconda](https://www.anaconda.com/products/distribution) to manage your environment.

### 2. Create a Conda Environment and Install Dependencies

Create a new conda environment (e.g., `btk_env`) and install the required tools:

```bash
conda create -n btk_env python=3.13
conda activate btk_env
```


Then install additional dependencies using conda. For example:

#### Install BLAST+, Bowtie2, and SAMtools from the bioconda channel

```bash
conda install -c bioconda blast+ bowtie2 samtools

# BlobToolKit2 is not available as a conda package,
# Install it via pip or follow its installation instructions.

```bash
pip install blobtoolkit
```

By default, the script assumes that BlobToolKit2 is located at:
/home/FM/user_name/miniforge3/envs/btk_env/bin/blobtools
Adjust the --blobtools2 option if your installation is in a different location.

### 3. Obtain the nt Database (optinal and use the pre-downloaded instead)

```bash
# (Optional) Set your desired BLASTDB directory
export BLASTDB=~/nt_db

# Create the BLASTDB directory if it doesn't exist
mkdir -p "$BLASTDB"

# Use update_blastdb.pl to download and decompress the nt database.
# This will download all parts of the nt database.
update_blastdb.pl nt --decompress
```

#### The nt BLAST database is required for BLAST searches. Download the nt database prefix and the taxonomy database (optinal):

```bash
#1.	Download the Taxonomy Database (taxdb):
    wget ftp://ftp.ncbi.nlm.nih.gov/blast/db/taxdb.tar.gz

#2.	Extract the Taxonomy Database:
    mkdir -p ~/blast_db
	tar -xzvf taxdb.tar.gz -C ~/blast_db

#3.	Set the BLASTDB Environment Variable:
	#Add the following to your shell profile (e.g., ~/.bashrc):
		export BLASTDB=~/blast_db
	#Then reload your profile:
		source ~/.bashrc

#4. Obtain the Taxdump Directory
# Download the NCBI taxdump archive from:
	ftp://ftp.ncbi.nlm.nih.gov/pub/taxonomy/taxdump.tar.gz
# Extract it into a directory (for example, /home/FM/ysun/Storage/ysun_Phoebe/blobtoolkit/taxdump):
	mkdir -p /home/FM/ysun/Storage/ysun_Phoebe/blobtoolkit/taxdump
	tar -xzvf taxdump.tar.gz -C /home/FM/ysun/Storage/ysun_Phoebe/blobtoolkit/taxdump
```

### 4. Usage (use the nt BLAST database and taxdump location as default)

The pipeline script is written in Bash and accepts the following command-line options:
	•	--fasta: Assembly FASTA file (required).
	•	-1: Forward reads FASTQ file (optional).
	•	-2: Reverse reads FASTQ file (optional).
	•	--nt: Path to the nt BLAST database prefix (optional; default: /home/FM/ysun/Storage/ysun_Phoebe/blobtoolkit/nt/nt).
	•	--taxdump: Path to the taxdump directory (optional; default: /home/FM/ysun/Storage/ysun_Phoebe/blobtoolkit/taxdump).
	•	-T or --threads: Number of CPU cores to use (required).
	•	--blobtools2: Path to the BlobToolKit2 executable (optional; default: /home/FM/ysun/miniforge3/envs/btk_env/bin/blobtools).

Example Command

bash filter_lichen_assemblies.sh --fasta assembly.fasta -1 reads_1.fq.gz -2 reads_2.fq.gz \
    --nt /home/FM/ysun/Storage/ysun_Phoebe/blobtoolkit/nt/nt \
    --taxdump /home/FM/ysun/Storage/ysun_Phoebe/blobtoolkit/taxdump -T 20 \
    --blobtools2 /home/FM/ysun/miniforge3/envs/btk_env/bin/blobtools


### 5. What the Script Does
	1.	Mapping Reads (Optional):
If paired-end reads are provided (-1 and -2), the script:
	•	Builds a Bowtie2 index for the assembly.
	•	Maps the reads to the assembly.
	•	Sorts the alignments into a BAM file.
	•	Forces creation of a CSI index using samtools index -c (required by BlobToolKit2).
	2.	Generating BLAST Hits:
Runs BLASTn against the nt database to obtain taxonomic hits. If the BLAST output file already exists, this step is skipped.
	3.	Creating a BlobDir:
Uses BlobToolKit2’s add command with --create and --replace to generate a BlobDir dataset from:
	•	The assembly FASTA.
	•	Coverage information (if available).
	•	BLAST hits.
	•	The provided taxdump directory.
	4.	Filtering Contigs:
Uses BlobToolKit2’s filter command to remove contigs that:
	•	Have coverage less than 0.1×.
	•	Are shorter than 1000 bp.
	•	Are assigned to contaminant domains (Bacteria, Viruses, or Archaeplastida).
The filtered assembly is saved as <basename>.filtered.fasta in the OUTPUT directory.

Output Files
	•	BlobDir Dataset:
Created in a directory named blobdir_<basename> (e.g., blobdir_assembly).
	•	Filtered Assembly:
Saved in the OUTPUT directory (default: blobtools) with the filename <basename>.filtered.fasta.

Additional Notes
	•	Taxonomy Database Warning:
If BLAST issues warnings about taxonomy name lookups (e.g., “Taxonomy name lookup from taxid requires installation of taxdb database…”), ensure that you have downloaded and extracted taxdb.tar.gz from
ftp://ftp.ncbi.nlm.nih.gov/blast/db/taxdb.tar.gz
and that the BLASTDB environment variable is set to the directory containing these files.
	•	Field Replacement:
The --replace flag in the BlobDir creation step forces recalculation of taxonomy fields if they already exist. Remove it if you want to preserve existing field values.
	•	Customizing Filters:
The --param options in the filter command let you adjust numeric thresholds (e.g., for coverage and contig length) and to exclude contigs based on taxonomy. Modify these parameters as needed.
