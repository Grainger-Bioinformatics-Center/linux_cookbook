# Maker Installation

This installation instruction is modified from installation guide by Yandell Lab ([http://www.yandell-lab.org/software/maker.html](http://www.yandell-lab.org/software/maker.html)).

# Dependency

Maker needs Perl and Bioperl for installation

## Perl

**Need to have perl 5.8.0 or higher installed and modules as below:**
  
 Installed from conda or CPAN:
 
	- *DBI	conda install -c bioconda perl-dbi
	- *DBD::SQLite	conda install -c bioconda perl-dbd-sqlite
	- *forks	conda install -c bioconda perl-forks
	- *forks::shared
	- *File::Which	conda install -c bioconda perl-file-which
	- *Perl::Unsafe::Signals	conda install -c bioconda perl-perl-unsafe-signals
	- *Bit::Vector	conda install -c bioconda perl-bit-vector
	- *Inline::C	conda install -c bioconda perl-inline-c
	- *IO::All	conda install -c bioconda perl-io-all
	- *IO::Prompt	conda install -c bioconda perl-io-prompt
		
1.  Type 'perl -MCPAN -e shell' to access the CPAN shell.  You may have to answer some configuration questions if this is your first time starting CPAN. You can normally just hit enter to accept CPAN defaults. You may have to be logged in as 'root' or use sudo to install modules via CPAN. If you don't have root access, then install local::lib from http://www.cpan.org using the bootstrap method to setup a non-root CPAN install location.
	
 2.  Type 'install DBI' in CPAN to install the first module, then type 'install DBD::SQLite' to install the next one, and so on.
  
   
## Install BioPerl 1.6 or higher

**Quick and dirty installation (not full BioPerl package)**

 1.  Use the conda installation by conda install -c bioconda perl-bioperl
 2.  Or Download and unpack the most recent BioPerl package to a directory of your choice, or use Git to access the most current version of BioPerl. See http://www.bioperl.org for details on how to download using Git. You will then need to set PERL5LIB in your .bash_profile to the location of bioperl (i.e. export PERL5LIB="/usr/local/bioperl-live:$PERL5LIB").

**Full BioPerl instalation via CPAN (soduer)**
	
1.  Type perl -MCPAN -e shell into the command line to set up CPAN on your computer before installing bioperl (CPAN helps install perl dependencies needed to run bioperl).  For the most part just accept any default options by hitting enter during setup.
		
 2.  Type install Bundle::CPAN on the cpan command line.  Once again just press enter to accept default installation options.

 3. Type install Module::Build on the cpan command line.  Once again just press enter to accept default installation options.
      
 4. Type install Bundle::BioPerl on the cpan command line.  Once again press enter to accept default installation options.

# External software

Maker needs extrernal software for gene prediction.

## NCBI-BLAST 

**ncbi-blast is usually globly installed, so you can skip this**

1.  Unpack the tar file into the directory of your choice (i.e. /usr/local).
		
 2.  Add the location where you installed NCBI-BLAST to your PATH variable in .profile (i.e. export PATH=/home/FM/\$USERNAME/opt/ncbi-blast:\$PATH).

## SNAP

**Download from http://korflab.ucdavis.edu/software.html**

 
1.  Unpack the SNAP tar file into the directory of your choice (ie /home/FM/$USERNAME/opt)
		
 2.  Add the following to your .bash_profile file (value depends on where you choose to install snap):  export PATH=/home/FM/$USERNAME/opt/snap/Zoe

 3. Navigate to the directory where snap was unpacked (i.e. /home/FM/$USERNAME/opt/snap) and type make
      
 4. Add the location where you installed SNAP to your PATH variable in .profile (i.e. export PATH=/home/FM/\$USERNAME/opt/snap:\$PATH).
		

## RepeatMasker

**Download from http://www.repeatmasker.org**

 1. RepeatMasker requires a program called TRF. Downloaded from http://tandem.bu.edu/trf/trf.html
 
 2. The TRF download will contain a single executable file.  You will need to rename the file from whatever it is to 'trf'.

 3. Make it executable by typing `chmod a+x trf`.  Put it in the .../RepeatMasker directory.
 
 4. Unpack RepeatMasker to the directory of your choice (i.e. /home/FM/$USERNAME/opt).
 
 5. Installed WuBlast or RMBlast. *Not recomend using cross_match*.
		`conda install -c bioconda rmblast`

 6. In the RepeatMasker directory type `perl ./configure`. You will be asked to identify the location of perl, rmblast/wublast, and trf.  The script expects the paths to the folders containing the executables (pointing to a folder the path must end in a '/' character).

 7. Add the location where you installed RepeatMasker to your PATH variable in .profile (i.e. export PATH=/home/FM/\$USERNAME/opt/RepeatMasker:\$PATH).

 8. You must register at http://www.girinst.org and download the Repbase repeat database, Repeat Masker edition, for RepeatMasker to work.
 
 9. Unpack the contents of the RepBase tarball into the RepeatMasker/Libraries directory.

## Exonerate

**Download from http://www.ebi.ac.uk/~guy/exonerate**

1.  Exonerate has pre-comiled binaries for many systems; however, you can install it via conda
	
        conda install -c bioconda exonerate

# Maker main program

**Download from http://www.yandell-lab.org**

 1. Unpack the MAKER tar file into the directory of your choice (i.e. ~/opt). `tar zxvf maker-3.01.03.tgz`
 
 2. Go to the MAKER src/ directory. `cd ~/opt/maker/src`
 
 3. Configuration using `perl Build.PL`
 
 4. Installing missing dependencies `./Build installdeps`
 
 5. Installation using `./Build install`
 
 6. Installation AUGUSTUS using `./Build augustus`
 
 7. Add the following to your .profile if you haven't already:
		
		`export ZOE="where_snap_is/Zoe"`

		`export AUGUSTUS_CONFIG_PATH="where_augustus_is/config`

 6. Add the location where you installed MAKER to your PATH variable in .profile (i.e. export PATH=/home/FM/\$USERNAME/opt/maker/bin:\$PATH).

 7. Run a test of MAKER as shown in the MAKER README file.


