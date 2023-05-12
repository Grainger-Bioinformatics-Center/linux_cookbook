# Storage Drive usage

This is an instruction for compressing files and folders for the storage server. The storage server is shared among all servers, you can store your data by sort them into different folders for different server or mixed with the combined folder. But please do not put duplicated files into the storage server.

## Reads sequence files (fastq/fq)

Reads files need to be sorted into different technologies (Illumina/Pacbio/Nanopore) and storage using gzip compressed format.
For compression:
    gzip *.fastq
For decompression:
    gzip -d sample.fastq.gz

## Folders need to be compressed for storage unless you need to use them frequently

### Compression

**Compress a single file**
Compress a single file as file.gz using gzip (the original file will be removed after compression)
    gzip sample.fastq

**Compress complete directory**
1. Compress the complete folder as a tar.gz archive (recommended standard for working with Ubuntu/Linux)
    tar -zcvf samples_compressed.tar.gz /path/to/sample/directory/
2. compress a complete folder as a single zip file for use in Windows
    zip -r samples.zip sample_folder/
3.Change gzip level used in tar archive (default compression level is 6, max level is 9)
    tar -I 'gzip -9' -cvf samples_compressed.tar.gz sample_directory/

### Decompression

**.zip**
Decompress .zip folder
    unzip samples.zip

**.gz**
1. Decompress .gz file (compressed .gz file will be removed after decompression)
    gzip -d sample.fastq.gz
2. View the content of a .gz file
    zcat sample.fastq.gz
3. View top 20 lines (pass decompressed content via unix pipe to head command)
    zcat sample.fastq.gz | head -20
**.tar.gz**
1. Decompress .tar.gz files
    tar -zxvf samples.tar.gz
2. View the top 20 lines (pass decompressed file into a pipe: extract all tar archive files to standard output)
    tar -zxOf samples.tar.gz | head -20

### Extract a single file from tar archive

**List content (all files) of a .tar.gz archive**
    tar -tf samples.tar.gz

**Extract the selected file from .tar.gz archive**
    tar -zxvf samples.tar.gz sample_1.fastq
