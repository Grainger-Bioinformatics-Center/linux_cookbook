# Fungal Genome Annotation Pipeline

This repository provides a comprehensive, step-by-step command-line workflow to annotate a fungal genome using **RepeatModeler**, **RepeatMasker**, and **Funannotate**, with RNA‑seq evidence. Each section details commands, inputs, and expected outputs.

---

## Table of Contents

1. [Dependencies](#dependencies)
2. [Input Data](#input-data)
3. [Directory Structure](#directory-structure)
4. [Repeat Library Construction (RepeatModeler)](#repeat-library-construction-repeatmodeler)
5. [Repeat Masking in Iterative Rounds (RepeatMasker)](#repeat-masking-in-iterative-rounds-repeatmasker)
6. [Gene Prediction and Annotation (Funannotate)](#gene-prediction-and-annotation-funannotate)
7. [Outputs Summary](#outputs-summary)
8. [License](#license)

---

## Dependencies

Install the following tools in your `$PATH` (we recommend a conda environment):

- **RepeatModeler** v2.0+
- **RepeatMasker** (with NCBI or RMBlast engine and RepBase access)
- **Funannotate** v1.8+
- **Hisat2**, **Trinity**, **PASA** (for `funannotate train`)
- **Augustus**, **GeneMark-ES**, **BUSCO**, **SignalP**, **tRNAscan-SE** (Funannotate dependencies)
- **BEDTools**, **seqtk**, **datamash**, **awk**, **seqkit** (utilities)
- **InterProScan** (for functional annotation)

> **Tip:** Create a conda environment:
> ```bash
> conda create -n annotate_env python=3.9 repeatmodeler repeatmasker funannotate augustus genemark-es busco signalp trnascan-se hisat2 trinity pasa bedtools seqtk datamash seqkit interproscan -c bioconda -c conda-forge
> conda activate annotate_env
> ```

---

## Input Data

Place your input files under a `data/` directory:

- `data/genome.fasta` : Assembled fungal genome (FASTA)
- `data/reads_R1.fastq.gz`, `data/reads_R2.fastq.gz` : Paired-end RNA‑seq reads

---

## Directory Structure

After running, you will have:

```
├── data/
│   ├── genome.fasta
│   ├── reads_R1.fastq.gz
│   └── reads_R2.fastq.gz
├── logs/                # Logs for each step
├── 01_simple_out/       # Round 1 masking
├── 02_fungi_out/        # Round 2 masking
├── 03_known_out/        # Round 3 masking
├── 04_unknown_out/      # Round 4 masking
├── 05_full_out/         # Combined repeat outputs
├── fun/                 # Funannotate output (train, predict, annotate)
└── README.md            # This file
```

---

## Repeat Library Construction (RepeatModeler)

1. **Build database**
   ```bash
   BuildDatabase -name GenomeDB data/genome.fasta
   ```
   - **Input:** `data/genome.fasta`
   - **Output:** `GenomeDB.*` files (database files)

2. **Run RepeatModeler**
   ```bash
   RepeatModeler -pa 16 -database GenomeDB -LTRStruct 2>&1 | tee logs/repeatmodeler.log
   ```
   - **Output:** `GenomeDB-families.fa` (de novo repeat library)

3. **Prefix and split library**
   ```bash
   seqkit fx2tab < GenomeDB-families.fa \
     | awk '{print "MySpecies_" $0}' \
     | seqkit tab2fx > GenomeDB-families.prefix.fa

   seqkit fx2tab < GenomeDB-families.prefix.fa \
     | grep -v "Unknown" | seqkit tab2fx > GenomeDB-families.known.fa

   seqkit fx2tab < GenomeDB-families.prefix.fa \
     | grep "Unknown"  | seqkit tab2fx > GenomeDB-families.unknown.fa
   ```
   - **Output:**
     - `GenomeDB-families.prefix.fa`
     - `GenomeDB-families.known.fa`
     - `GenomeDB-families.unknown.fa`

---

## Repeat Masking in Iterative Rounds (RepeatMasker)

### Round 1: Simple repeats & low-complexity
```bash
RepeatMasker -pa 8 -a -e ncbi -dir 01_simple_out -noint -xsmall data/genome.fasta \
  2>&1 | tee logs/01_simplemask.log
```
- **Output:**
  - `01_simple_out/genome.simple_mask.masked.fasta`
  - `.out`, `.align`, `.tbl`, `.cat.gz`

### Round 2: Known fungal repeats
```bash
RepeatMasker -pa 16 -a -e ncbi -dir 02_fungi_out -nolow \
  -species fungi 01_simple_out/genome.simple_mask.masked.fasta \
  2>&1 | tee logs/02_fungimask.log
```
- **Output:** `02_fungi_out/genome.fungi_mask.masked.fasta`, `.out`, `.align`, `.tbl`, `.cat.gz`

### Round 3: Species-specific known repeats
```bash
RepeatMasker -pa 16 -a -e ncbi -dir 03_known_out -nolow \
  -lib GenomeDB-families.known.fa \
  02_fungi_out/genome.fungi_mask.masked.fasta \
  2>&1 | tee logs/03_knownmask.log
```
- **Output:** `03_known_out/genome.known_mask.masked.fasta`, `.out`, `.align`, `.tbl`, `.cat.gz`

### Round 4: Species-specific unknown repeats
```bash
RepeatMasker -pa 16 -a -e ncbi -dir 04_unknown_out -nolow \
  -lib GenomeDB-families.unknown.fa \
  03_known_out/genome.known_mask.masked.fasta \
  2>&1 | tee logs/04_unknownmask.log
```
- **Output:** `04_unknown_out/genome.unknown_mask.masked.fasta`, `.out`, `.align`, `.tbl`, `.cat.gz`

### Combine all rounds
```bash
mkdir -p 05_full_out
cat 01_simple_out/*.cat.gz 02_fungi_out/*.cat.gz 03_known_out/*.cat.gz 04_unknown_out/*.cat.gz \
  > 05_full_out/genome.full_mask.cat.gz

cat 01_simple_out/*.out \
  <(tail -n +4 02_fungi_out/*.out) \
  <(tail -n +4 03_known_out/*.out) \
  <(tail -n +4 04_unknown_out/*.out) \
  > 05_full_out/genome.full_mask.out

cat 01_simple_out/*.align 02_fungi_out/*.align 03_known_out/*.align 04_unknown_out/*.align \
  > 05_full_out/genome.full_mask.align
```

### Summarize combined repeats
```bash
ProcessRepeats -a -species fungi 05_full_out/genome.full_mask.cat.gz \
  2>&1 | tee logs/05_fullmask.log
```

### Convert to GFF3 & soft-mask genome
```bash
rmOutToGFF3custom -o 05_full_out/genome.full_mask.out > 05_full_out/genome.full_mask.gff3

bedtools maskfasta -soft -fi data/genome.fasta \
  -bed 05_full_out/genome.full_mask.gff3 \
  -fo 05_full_out/genome.full_mask.soft.fasta
```

---

## Gene Prediction and Annotation (Funannotate)

### 1. Train with RNA‑seq
```bash
funannotate train -i 05_full_out/genome.full_mask.soft.fasta -o fun \
  -l data/reads_R1.fastq.gz -r data/reads_R2.fastq.gz \
  --jaccard_clip --stranded no --cpus 16
```
- **Output:** `fun/` contains aligned BAMs, Trinity transcripts, PASA GFF3

### 2. Predict gene models
```bash
funannotate predict -i 05_full_out/genome.full_mask.soft.fasta -o fun \
  -s "Genus species" --strain "MyStrain" --cpus 16 \
  --augustus_species anidulans --busco_db fungi \
  --transcript_evidence fun/training/funannotate_train.trinity.fasta \
  --other_gff fun/training/funannotate_train.transcripts.gff3 \
  --name SPECIES_
```
- **Output:** `fun/predict_results/` with GFF3, proteins.fa, transcripts.fa

### 3. InterProScan
```bash
interproscan.sh -i fun/predict_results/Genus_species.proteins.fa \
  -b interpro_out -pa -iprlookup -goterms --cpu 16
```
- **Output:** `interpro_out.xml`, `.tsv`, etc.

### 4. Functional annotation
```bash
funannotate annotate -i fun -o fun \
  --species "Genus species" --strain "MyStrain" \
  --busco_db ascomycota --iprscan interpro_out.xml --cpus 8
```
- **Output:** `fun/annotate_results/` with final GFF3 and annotation tables

---

## Outputs Summary

- **Masked genome:** `05_full_out/genome.full_mask.soft.fasta`
- **Repeat annotations:** GFF3 and summary tables in `05_full_out/`
- **Predicted genes:** `fun/predict_results/Genus_species.gff3`, `.proteins.fa`, `.transcripts.fa`
- **Functional annotations:** `fun/annotate_results/`

---

## License

This pipeline is released under the MIT License.
