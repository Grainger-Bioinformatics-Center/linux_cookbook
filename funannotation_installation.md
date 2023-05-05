# Funannotation installation

The funannotate pipeline is written in python. It's easy to use conda for installation due to funannotate has a lot of dependencies.

## Installation

test

### Bioconda install:

**add appropriate channels:**
   
    conda config --add channels defaults
    conda config --add channels bioconda
    conda config --add channels conda-forge
	
**install with new environment:**
   
    conda create -n funannotate "python>=3.6,<3.9" funannotate

   
### mamba install:

If conda is taking forever to solve the environment, mamba is the way to speed up the process

**install mamba into base environment:**
   
    conda install -n base mamba
	
**use mamba as drop in replacement:**
   
    mamba create -n funannotate funannotate

### GeneMark-ES/ET install:

GeneMark-ES/ET needs to be installed manually due to it required academic license agreement

Fill the academic license agreement and download from: http://topaz.gatech.edu/GeneMark/license_download.cgi

 1.  Download the software and key

    cd ~/opt   
    wget http://topaz.gatech.edu/GeneMark/tmp/GMtool_lqacT/gm_key_64.gz
    wget http://topaz.gatech.edu/GeneMark/tmp/GMtool_lqacT/gm_et_linux_64.tar.gz
    tar xzvf gm_et_linux_64.tar.gz
	gunzip gm_key_64.gz
	cp gm_key_64 ~/.gm_key

2.  Change all of the GeneMark script headers to conda perl path

    cd ~/opt/gm_et_linux_64
    which perl
    perl ./change_path_in_perl_scripts.pl <location from the which perl command>

3.  Add GeneMark to .profile

    export PATH=$PATH:/your_home_folder/opt/gm_et_linux_64


### Setup database for funannotation:
	
1.  start up conda ENV

    conda activate funannotate

2.  check that all modules are installed

    funannotate check --show-versions

3.  download/setup databases to a writable/readable location

    funannotate setup -d ~/Data/funannotate_db
	
4.  set ENV variable for $FUNANNOTATE_DB and GENEMARK_PATH

    echo "export FUNANNOTATE_DB=~/Data/funannotate_db" >> /conda/installation/path/envs/funannotate/etc/conda/activate.d/funannotate.sh
	echo "unset FUNANNOTATE_DB" >> /conda/installation/path/envs/funannotate/etc/conda/deactivate.d/funannotate.sh
	
	echo "export GENEMARK_PATH=~/opt/gmes_linux_64" >> /conda/installation/path/envs/funannotate/etc/conda/activate.d/funannotate.sh
	echo "unset GENEMARK_PATH" >> /conda/installation/path/envs/funannotate/etc/conda/deactivate.d/funannotate.sh
	
If the bio-perl is not detect after you install it with conda, please do

    export PERL5LIB=/your_conda_path/envs/virsorter/lib/perl5/site_perl/5.22.0/ 
	
### run tests for funannotation

    funannotate test -t all --cpus X

