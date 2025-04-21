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
8. [NCBI Submission Preparation](#ncbi-submission-preparation)

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
   seqkit fx2tab < GenomeDB-families.fa \\
     | awk '{print "MySpecies_" $0}' \\
     | seqkit tab2fx > GenomeDB-families.prefix.fa

   seqkit fx2tab < GenomeDB-families.prefix.fa \\
     | grep -v "Unknown" | seqkit tab2fx > GenomeDB-families.known.fa

   seqkit fx2tab < GenomeDB-families.prefix.fa \\
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
RepeatMasker -pa 8 -a -e ncbi -dir 01_simple_out -noint -xsmall data/genome.fasta \\
  2>&1 | tee logs/01_simplemask.log
```
- **Output:** Masked genome and report files in `01_simple_out/`

### Round 2: Known fungal repeats
```bash
RepeatMasker -pa 16 -a -e ncbi -dir 02_fungi_out -nolow \\
  -species fungi 01_simple_out/genome.simple_mask.masked.fasta \\
  2>&1 | tee logs/02_fungimask.log
```
- **Output:** Masked genome and report files in `02_fungi_out/`

### Round 3: Species-specific known repeats
```bash
RepeatMasker -pa 16 -a -e ncbi -dir 03_known_out -nolow \\
  -lib GenomeDB-families.known.fa \\
  02_fungi_out/genome.fungi_mask.masked.fasta \\
  2>&1 | tee logs/03_knownmask.log
```
- **Output:** Masked genome and report files in `03_known_out/`

### Round 4: Species-specific unknown repeats
```bash
RepeatMasker -pa 16 -a -e ncbi -dir 04_unknown_out -nolow \\
  -lib GenomeDB-families.unknown.fa \\
  03_known_out/genome.known_mask.masked.fasta \\
  2>&1 | tee logs/04_unknownmask.log
```
- **Output:** Masked genome and report files in `04_unknown_out/`

### Combine all rounds
```bash
mkdir -p 05_full_out
cat 01_simple_out/*.cat.gz 02_fungi_out/*.cat.gz 03_known_out/*.cat.gz 04_unknown_out/*.cat.gz \\
  > 05_full_out/genome.full_mask.cat.gz

cat 01_simple_out/*.out \\
  <(tail -n +4 02_fungi_out/*.out) \\
  <(tail -n +4 03_known_out/*.out) \\
  <(tail -n +4 04_unknown_out/*.out) \\
  > 05_full_out/genome.full_mask.out

cat 01_simple_out/*.align 02_fungi_out/*.align 03_known_out/*.align 04_unknown_out/*.align \\
  > 05_full_out/genome.full_mask.align
```

### Summarize combined repeats
```bash
ProcessRepeats -a -species fungi 05_full_out/genome.full_mask.cat.gz \\
  2>&1 | tee logs/05_fullmask.log
```

### Convert to GFF3 & soft-mask genome
```bash
rmOutToGFF3custom -o 05_full_out/genome.full_mask.out > 05_full_out/genome.full_mask.gff3

bedtools maskfasta -soft -fi data/genome.fasta \\
  -bed 05_full_out/genome.full_mask.gff3 \\  
  -fo 05_full_out/xxx.full_mask.soft.fasta
```

---

## Gene Prediction and Annotation (Funannotate)

### 1. Prepare masked genome for Funannotate
Use your project’s filename prefix **`xxx`** when substituting paths below.  
```bash
genome_fasta="05_full_out/xxx.full_mask.soft.fasta"
```

### 2. Train with RNA‑seq
```bash
funannotate train -i "$genome_fasta" -o fun \\
  -l data/reads_R1.fastq.gz -r data/reads_R2.fastq.gz \\
  --jaccard_clip --stranded no --cpus 16
```

### 3. Predict gene models
```bash
funannotate predict -i "$genome_fasta" -o fun \\
  -s "Genus species" --strain "MyStrain" --cpus 16 \\
  --augustus_species anidulans --busco_db fungi \\
  --transcript_evidence fun/training/funannotate_train.trinity.fasta \\
  --other_gff fun/training/funannotate_train.transcripts.gff3 \\
  --name SPECIES_
```

### 4. InterProScan
```bash
interproscan.sh -i fun/predict_results/Genus_species.proteins.fa \\
  -b interpro_out -pa -iprlookup -goterms --cpu 16
```

### 5. Functional annotation
```bash
funannotate annotate -i fun -o fun \\
  --species "Genus species" --strain "MyStrain" \\
  --busco_db ascomycota --iprscan interpro_out.xml --cpus 8
```

---

## Outputs Summary

- **Masked genome for annotation:** `05_full_out/xxx.full_mask.soft.fasta`
- **Repeat annotations:** GFF3 and summary tables in `05_full_out/`
- **Predicted genes:** `fun/predict_results/Genus_species.gff3`, `.proteins.fa`, `.transcripts.fa`
- **Functional annotations & tables:** `fun/annotate_results/` including `xxx.tbl` and `xxx.contigs.fa`

---

## NCBI Submission Preparation

### 1. Obtain NCBI submission template (`template.sbt`)
Visit NCBI’s “Create Submission Template” page, enter submitter and organism details, and download `template.sbt`.

### 2. Register BioProject & BioSample and obtain Locus Tag Prefix
Use the NCBI BioProject and BioSample Submission Portals to create entries. Record the assigned locus tag prefix (e.g., `ACLMJK`).

### 3. Prepare files for table2asn
```bash
tbl_file="fun/annotate_results/xxx.tbl"
contig_fasta="fun/annotate_results/xxx.contigs.fa"
template="template.sbt"
locus_prefix="ACLMJK"
```

### 4. Generate ASN.1 submission file
```bash
table2asn -i "$contig_fasta" \\
  -f "$tbl_file" \\
  -t "$template" \\
  -locus-tag-prefix "$locus_prefix" \\
  -euk -a s -verbose -M n
```

---

# Example Error Reports (Q&A)

Below are detailed discrepancy reports from NCBI’s ASN discrepancy examples:

### EUKARYOTE_SHOULD_HAVE_MRNA  
**Explanation:** No mRNA feature present for CDS entries.  
**Suggestion:** Add appropriate mRNA features for all CDS features with matching `transcript_IDs` and `protein_IDs`.  
**Example:**  
```
EUKARYOTE_SHOULD_HAVE_MRNA: FATAL! No mRNA present
```  

### EXON_INTRON_CONFLICT  
**Explanation:** Exon and adjacent intron spans do not directly abut one another.  
**Suggestion:** Adjust exon/intron spans to be directly adjacent, or remove redundant exon/intron features if using CDS/mRNA.  
**Example:**  
```
EXON_INTRON_CONFLICT.asn:exon 1 lcl|ex1:1-10
EXON_INTRON_CONFLICT.asn:intron [intron] lcl|ex1:12-20
...
```  

### FIND_BADLEN_TRNAS  
**Explanation:** tRNA feature is longer than expected (>150 nt); likely an annotation error or archaeal intron.  
**Suggestion:** Verify annotation or join spans if intron present (archaea).  
**Example:**  
```
FIND_BADLEN_TRNAS: 1 tRNA is too long – over 150 nucleotides
```  

### GAPS  
**Explanation:** Genome sequence contains gaps (`N`s).  
**Suggestion:** Ignore if expected; otherwise, correct sequence or annotation.  
**Example:**  
```
GAPS: 1 sequence contains gaps
```  

### GENE_PRODUCT_CONFLICT  
**Explanation:** Coding regions share the same gene name but different product names.  
**Suggestion:** Verify gene symbols and products; decide whether to ignore or correct.  
**Example:**  
```
GENE_PRODUCT_CONFLICT: 2 coding regions have the same gene name (lptF) but a different product
```  

### INCONSISTENT_DBLINK  
**Explanation:** BioProject/BioSample DBLink values differ among parts of the assembly.  
**Suggestion:** Ensure all contigs share the same BioProject and BioSample IDs.  
**Example:**  
```
INCONSISTENT_DBLINK: DBLink Report (all present, inconsistent)
  BioSample: 2 have ‘SAMN01’, 2 have ‘SAMN02’
  BioProject: consistent
```  

### INCONSISTENT_STRUCTURED_COMMENTS  
**Explanation:** Structured comment fields (e.g., Assembly Method) differ across contigs.  
**Suggestion:** Standardize structured comments or correct mismatches.  
**Example:**  
```
INCONSISTENT_STRUCTURED_COMMENTS: Structured Comment Report (all present, inconsistent)
  Assembly Method: inconsistent
```  

### LONG_NO_ANNOTATION  
**Explanation:** Sequence >5000 nt has no annotation features.  
**Suggestion:** Add features if intended; otherwise, ignore informational warning.  
**Example:**  
```
1 bioseq is longer than 5000nt and has no features.
```  

### LOW_QUALITY_REGION  
**Explanation:** Region with many non-ACGT bases (excluding Ns).  
**Suggestion:** Check for non-ACGTN bases or add gap features for Ns.  
**Example:**  
```
LOW_QUALITY_REGION: 1 sequence contains low quality region
```  

### MISC_FEATURE_WITH_PRODUCT_QUAL  
**Explanation:** `misc_feature` has a `/product` qualifier (only allowed on CDS/RNA).  
**Suggestion:** Move `/product` to `/note` or use CDS/RNA feature.  
**Example:**  
```
MISC_FEATURE_WITH_PRODUCT_QUAL: 15 features have a product qualifier
```  

### MRNA_SHOULD_HAVE_PROTEIN_TRANSCRIPT_IDS  
**Explanation:** mRNA features lack matching `transcript_ID` and `protein_ID`.  
**Suggestion:** Add both qualifiers to each mRNA feature.  
**Example:**  
```
MRNA_SHOULD_HAVE_PROTEIN_TRANSCRIPT_IDS: no protein_id and transcript_id present
```  

### MULTIPLE_CDS_ON_MRNA  
**Explanation:** More than one CDS on a single mRNA feature.  
**Suggestion:** Provide separate mRNA features (and IDs) for each CDS.  
**Example:**  
```
MULTIPLE_CDS_ON_MRNA.asn:ex2 (length 247)
...
```  

### NO_LOCUS_TAGS  
**Explanation:** CDS and RNA features lack `locus_tag` qualifiers.  
**Suggestion:** Add `locus_tag` to all gene-related features.  
**Example:**  
```
NO_LOCUS_TAGS: FATAL! None of the 1871 genes has locus tag
```  

### PROTEIN_NAMES  
**Explanation:** All proteins share the same name.  
**Suggestion:** Assign distinct names for well-characterized proteins; accept draft.  
**Example:**  
```
PROTEIN_NAMES: All proteins have the same name 'hypothetical protein'
```  

### REQUIRED_STRAIN  
**Explanation:** Strain qualifier missing for organisms requiring it (e.g., fungi).  
**Suggestion:** Add appropriate `strain` qualifier.  
**Example:**  
```
REQUIRED_STRAIN: 7 biosources are missing required strain value
```  

### RRNA_NAME_CONFLICTS  
**Explanation:** rRNA product names not matching standard nomenclature.  
**Suggestion:** Use correct rRNA names (e.g., `16S ribosomal RNA`).  
**Example:**  
```
FATAL! 4 rRNA product names are not standard.
```  

### SEQ_SHORTER_THAN_200BP  
**Explanation:** Contigs shorter than 200 nt present.  
**Suggestion:** Remove or justify short contigs.  
**Example:**  
```
SEQ_SHORTER_THAN_200BP: 2 contigs are shorter than 200 nt
```  

### SEQ_SHORTER_THAN_50BP  
**Explanation:** Sequences shorter than 50 nt present.  
**Suggestion:** Remove these sequences.  
**Example:**  
```
SEQ_SHORTER_THAN_50BP: 3 sequences are shorter than 50 nt
```  

### SHORT_LNCRNA  
**Explanation:** lncRNA feature shorter than 200 nt.  
**Suggestion:** Confirm correct ncRNA class or adjust annotation.  
**Example:**  
```
SHORT_LNCRNA: 1 lncRNA feature is suspiciously short
```  

### SHORT_RRNA  
**Explanation:** rRNA feature shorter than expected length thresholds.  
**Suggestion:** Adjust spans, mark partial, or annotate as pseudo.  
**Example:**  
```
SHORT_RRNA: 1 rRNA feature is too short
```  

### SHOW_TRANSL_EXCEPT  
**Explanation:** `/transl_except` qualifier presence indicates non-standard translation.  
**Suggestion:** Verify correctness for valid exceptions (e.g., selenocysteine).  
**Example:**  
```
SHOW_TRANSL_EXCEPT: 3 coding regions have a translation exception
```  

...  

### UNUSUAL_NT  
**Explanation:** Bases other than A,C,G,T,N detected.  
**Suggestion:** Confirm ambiguous bases or fix sequence formatting.  
**Example:**  
```
UNUSUAL_NT: 1 sequence contains nucleotides that are not ATCG or N
```  

---