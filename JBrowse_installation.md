# JBrowse installation

JBrowse contains required dependencies for using Apollo

## Installation
	
    git clone https://github.com/gmod/jbrowse
    cd jbrowse
    ./setup.sh

## Trouble shooting

If the setup.sh shows following error:
	
	$./setup.sh
	
	Gathering system information ...done.
	NOTE: Legacy scripts wig-to-json.pl and bam-to-json.pl have been removed from setup. Their functionality has been superseded by add-bam-track.pl and add-bw-track.pl. If you require the old versions, please use JBrowse 1.12.3 or earlier.
	Installing node.js dependencies and building with webpack ...done.
	Installing Perl prerequisites ... failed.  See setup.log file for error messages. As a first troubleshooting step, make sure development libraries and header files for GD, Zlib, and libpng are installed and try again.
	
	Formatting Volvox example data ... failed.  See setup.log file for error messages.

	Formatting Yeast example data ... failed.  See setup.log file for error messages.


Please try these commands:
	
	rm -rf extlib
	bin/cpanm -v --notest -l extlib/ Bio::Perl@1.7.2
	./setup.sh