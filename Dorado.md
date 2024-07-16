# Nanopore basecalling with Dorado

Dorado is a high-performance, easy-to-use, open source basecaller for Oxford Nanopore reads. And it will be benefit from using the GPU server for accelerate the process due to using the PyTorch library. For more detail, Please see the orignal readme file from [Dorado](https://github.com/nanoporetech/dorado/blob/release-v0.7/README.md).

## Installation

Go to your opt folder in your home directory (create opt if you did not have), and download the file (version 0.72 as example):

```
#mkdir ~/opt
cd ~/opt
wget https://cdn.oxfordnanoportal.com/software/analysis/dorado-0.7.2-linux-x64.tar.gz
```

Unzip the tar.gz then you can call Dorado using the path

```
tar -xvzf dorado-0.7.2-linux-x64.tar.gz
~/opt/dorado-x.y.z-linux-x64/bin/dorado basecaller hac pod5s/ > calls.bam
```

## Basic running option:

Warning! Using only max up to two GPU before running the Dorado

```
$ export CUDA_VISIBLE_DEVICES=0
```

To see all options and their defaults, run `dorado -h` and `dorado <subcommand> -h`.

### Simplex basecalling

To run Dorado basecalling, using the automatically downloaded `hac` model on a directory of POD5 files or a single POD5 file _(.fast5 files are supported, but will not be as performant)_.

```
$ dorado basecaller hac pod5s/ > calls.bam
```

To basecall a single file, simply replace the directory `pod5s/` with a path to your data file.

If basecalling is interrupted, it is possible to resume basecalling from a BAM file. To do so, use the `--resume-from` flag to specify the path to the incomplete BAM file. For example:

```
$ dorado basecaller hac pod5s/ --resume-from incomplete.bam > calls.bam
```

`calls.bam` will contain all of the reads from `incomplete.bam` plus the new basecalls *(`incomplete.bam` can be discarded after basecalling is complete)*.   

### Duplex

To run Duplex basecalling, run the command:

```
$ dorado duplex sup pod5s/ > duplex.bam
```

### Sequencing Summary

The `dorado summary` command outputs a tab-separated file with read level sequencing information from the BAM file generated during basecalling. To create a summary, run:

```
$ dorado summary <bam> > summary.tsv
```

### Read Error Correction

Dorado supports single-read error correction with the integration of the [HERRO](https://github.com/lbcb-sci/herro) algorithm. HERRO uses all-vs-all alignment followed by haplotype-aware correction using a deep learning model to achieve higher single-read accuracies. The corrected reads are primarily useful for generating *de novo* assemblies of diploid organisms.

To correct reads, run:
```
$ dorado correct reads.fastq(.gz) > corrected_reads.fasta
```

Dorado correct only supports FASTX(.gz) as the input and generates a FASTA file as output. The input can be uncompressed or compressed with `bgz`. An index file is generated for the input FASTX file in the same folder unless one is already present. Please ensure that the folder with the input file is writeable by the `dorado` process and has sufficient disk space (no more than 10GB should be necessary for a whole genome dataset).

The error correction tool is both compute and memory intensive. As a result, it is best run on a system with multiple high performance CPU cores ( > 64 cores), large system memory ( > 256GB) and a modern GPU with a large VRAM ( > 32GB).

All required model weights are downloaded automatically by Dorado. However, the weights can also be pre-downloaded and passed via command line in case of offline execution. To do so, run:
```
$ dorado download --model herro-v1
$ dorado correct -m herro-v1 reads.fastq(.gz) > corrected_reads.fasta
```

## Troubleshooting:

### GPU Out of Memory Errors

Dorado operates on a broad range of GPUs but it is primarily developed for Nvidia A100/H100 and Apple Silicon. Dorado attempts to find the optimal batch size for basecalling. Nevertheless, on some low-RAM GPUs, users may face out of memory crashes.

A potential solution to this issue could be setting a manual batch size using the following command:

`dorado basecaller --batchsize 64 ...`

**Note:** Reducing memory consumption by modifying the `chunksize` parameter is not recommended as it influences the basecalling results.

### Low GPU Utilization

Low GPU utilization can lead to reduced basecalling speed. This problem can be identified using tools such as `nvidia-smi` and `nvtop`. Low GPU utilization often stems from I/O bottlenecks in basecalling. Here are a few steps you can take to improve the situation:

1. Opt for POD5 instead of .fast5: POD5 has superior I/O performance and will enhance the basecall speed in I/O constrained environments.
2. Transfer data to the local disk before basecalling: Slow basecalling often occurs because network disks cannot supply Dorado with adequate speed. To mitigate this, make sure your data is as close to your host machine as possible.
3. Choose SSD over HDD: Particularly for duplex basecalling, using a local SSD can offer significant speed advantages. This is due to the duplex basecalling algorithm's reliance on heavy random access of data.

