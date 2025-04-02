# RevBayes Installation Guide

This repository provides instructions to install RevBayes with MPI support using Conda. The installation uses the [Bioconda](https://anaconda.org/bioconda/revbayes) package for RevBayes and sets up the environment so you can run RevBayes in parallel with `mpirun`.

## Table of Contents

- [Prerequisites](#prerequisites)
- [Installation](#installation)
  - [1. Create and Activate a Conda Environment](#1-create-and-activate-a-conda-environment)
  - [2. Install Required Dependencies](#2-install-required-dependencies)
  - [3. Install RevBayes via Conda](#3-install-revbayes-via-conda)
- [Usage](#usage)
- [Troubleshooting](#troubleshooting)
- [License](#license)

## Prerequisites

Before proceeding, ensure you have the following installed:

- [Miniconda](https://docs.conda.io/en/latest/miniconda.html) or [Anaconda](https://www.anaconda.com/products/distribution)
- A C++ compiler (e.g., GCC)
- [OpenMPI](https://www.open-mpi.org/) (will be installed via Conda)
- Basic familiarity with the command line

## Installation

### 1. Create and Activate a Conda Environment

Create a dedicated Conda environment for RevBayes and activate it:

```bash
conda create -n revbayes-env -y
conda activate revbayes-env
```
### 2. Install Required Dependencies

Install OpenMPI, CMake, and the GCC compilers from the conda-forge channel. (If you’re on macOS or Windows, replace the compiler packages with the appropriate versions.)

```bash
conda install -c conda-forge openmpi cmake gcc_linux-64 gxx_linux-64 -y
```

### 3. Install RevBayes via Conda

Install the MPI-enabled version of RevBayes from Bioconda:

```bash
conda install -c bioconda revbayes -y
```

### Usage

After installation, you can run the MPI-enabled RevBayes executable (commonly named rb-mpi) using mpirun. For example, to run RevBayes with 4 processes:

```bash
mpirun -np 4 rb-mpi [additional arguments]
```

### Troubleshooting

•	MPI Library Consistency:
Ensure that the mpirun being used is from your active Conda environment:
```bash
which mpirun
```
It should point to a path within your revbayes-env.

•	Dynamic Linking Errors:
If you encounter linking issues, add your Conda environment’s library path to LD_LIBRARY_PATH:
```bash
export LD_LIBRARY_PATH=$CONDA_PREFIX/lib:$LD_LIBRARY_PATH
```

•	Clean Environment:
If problems persist, try removing and recreating the Conda environment:
```bash
conda remove -n revbayes-env --all
```
