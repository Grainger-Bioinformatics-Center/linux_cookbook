#!/usr/bin/perl
## Pombert Lab - Yukun, IIT, 2020
my $name = 'curate_annotations.pl';
my $version = '1.2'; ## Now with 3D

use strict; use warnings; use Getopt::Long qw(GetOptions); use FileHandle;

my $usage = <<"OPTIONS";

NAME		$name
VERSION		$version
SYNOPSIS	Displays lists of functions predicted per proteins. User can select or enter desired annotation.
		Creates a tab-delimited .curated list of annotations.
USAGE		curate_annotations.pl -r -i BEOM2.annotations -3D 3d_matches.txt

OPTIONS:
-r	Resumes annotation from last curated locus_tag
-i	Input file (generated from parse_annotators.pl)
-3D	List of 3D matches from GESAMT searches ## Generated with descriptive_GESAMT_matches.pl

OPTIONS
die "$usage\n" unless @ARGV;

my $input;
my $resume;
my $d3;
GetOptions(
	'i=s' => \$input,
	'r' => \$resume,
	'3D|3d=s' => \$d3
);

my %curated;
if ($resume){
	open RE, "<$input.curated";
	while (my $line = <RE>){
		chomp $line;
		if ($line =~ /^(\S+)\t(.*)$/){$curated{$1} = $2;}
	}
}
open IN, "<$input";
open OUT, ">>$input.curated"; OUT->autoflush(1); 

my %d3; my $d3_query;
if ($d3){
	open DD, "<$d3" or die "\nCan't open 3D matches file: $d3\n\n";
	while (my $line = <DD>){
		chomp $line;
		if ($line =~ /^### .*?(\w+)\-\w+\-\w+/){$d3_query = $1;}
		else {
			if ($line =~ /^\S+\s+\d+\s+\w+\s+\w\s+(\S+).*pdb\w+.ent.gz\s(.*)$/){
				my $qscore = $1;
				my $match = $2;
				push (@{$d3{$d3_query}}, "$qscore\t\t$match");
			}
		}
	}
}

my $call; my $count = 0; my $size; my $tab; my $x; my @col;
while (my $line = <IN>){
	chomp $line;
	if ($line =~ /^#/){next;}
	else{
		@col = split("\t", $line); $count++; $count = sprintf("%04d", $count);
		$size = scalar@col;
		## $col[0] => queries
		## $col[1] and $col[2] => SwissProt Evalues and Annotations
		## $col[3] and $col[4] => TREMBL Evalues and Annotations
		## $col[5] and $col[6] => Pfam Evalues and Annotations
		## $col[7] and $col[8] => TIGRFAM Evalues and Annotations
		## $col[9] and $col[10] => HAMAP Scores and Annotations
		## $col[11] and $col[12] => CDD Evalues and Motifs
		## $col[13] and $col[14] => reference organism (if exists)
		if (exists $curated{$col[0] }){next;}
		elsif (($size != 15)&&(!defined $d3)&&($col[2] eq 'hypothetical protein')&&($col[4] eq 'hypothetical protein')&&($col[6] eq 'hypothetical protein')&&($col[8] eq 'hypothetical protein')&&($col[10] eq 'hypothetical protein')&&($col[12] eq 'no motif found')){print OUT "$col[0]\thypothetical protein\n"; $curated{$col[0]} = 'in progress';}
		elsif (($size != 15)&&(defined $d3)&&(!defined $d3{$col[0]})&&($col[2] eq 'hypothetical protein')&&($col[4] eq 'hypothetical protein')&&($col[6] eq 'hypothetical protein')&&($col[8] eq 'hypothetical protein')&&($col[10] eq 'hypothetical protein')&&($col[12] eq 'no motif found')){print OUT "$col[0]\thypothetical protein\n"; $curated{$col[0]} = 'in progress';}
		elsif (($size == 15)&&(!defined $d3)&&($col[2] eq 'hypothetical protein')&&($col[4] eq 'hypothetical protein')&&($col[6] eq 'hypothetical protein')&&($col[8] eq 'hypothetical protein')&&($col[10] eq 'hypothetical protein')&&($col[12] eq 'no motif found')&&($col[14] =~ /no match found/)){print OUT "$col[0]\thypothetical protein\n"; $curated{$col[0]} = 'in progress';}
		elsif (($size == 15)&&(defined $d3)&&(!defined $d3{$col[0]})&&($col[2] eq 'hypothetical protein')&&($col[4] eq 'hypothetical protein')&&($col[6] eq 'hypothetical protein')&&($col[8] eq 'hypothetical protein')&&($col[10] eq 'hypothetical protein')&&($col[12] eq 'no motif found')&&($col[14] =~ /no match found/)){print OUT "$col[0]\thypothetical protein\n"; $curated{$col[0]} = 'in progress';}
		else{
			$curated{$col[0]} = 'in progress';
			print "\nPutative annotation(s) found for protein #$count: $col[0]:\n";
			
			$x = length($col[1]); tab(); print "1.\tSWISSPROT:\t$col[1]"."$tab"."$col[2]\n";
			$x = length($col[3]); tab(); print "2.\tTREMBL:\t\t$col[3]"."$tab"."$col[4]\n";
			$x = length($col[5]); tab(); print "3.\tPfam:\t\t$col[5]"."$tab"."$col[6]\n";
			$x = length($col[7]); tab(); print "4.\tTIGRFAM:\t$col[7]"."$tab"."$col[8]\n";
			$x = length($col[9]); tab(); print "5.\tHAMAP:\t\t$col[9]"."$tab"."$col[10]\n";
			$x = length($col[11]); tab(); print "6.\tCDD:\t\t$col[11]"."$tab"."$col[12]\n";
			if ($size == 15){
				$x = length($col[13]); tab(); print "7.\tReference:\t$col[13]"."$tab"."$col[14]\n";
				threed();
				print "\nPlease enter selection [1-7] to assign annotation, [0] to annotate as 'hypothetical protein', [m] for manual annotation, or [x] to exit\n";
			}
			else{print "\nPlease enter selection [1-6] to assign annotation, [0] to annotate as 'hypothetical protein', [m] for manual annotation, or [x] to exit\n";}
			chomp ($call = <STDIN>);
			if ($call eq 'x'){exit;}
			elsif ($call eq 'm'){
				print "Enter desired annotation: ";
				chomp (my $annot = <STDIN>);
				print OUT "$col[0]\t$annot\n";
			}
			elsif ($call =~ /^[0123456]$/){
				if ($call == 0){print OUT "$col[0]\thypothetical protein\n";}
				else{my $num = $call*2; print OUT "$col[0]\t$col[$num]\n";}
			}
			elsif (($size == 15) && ($call =~ /^[7]$/)){
				my $num = $call*2; print OUT "$col[0]\t$col[$num]\n";
			}
			else {print "Wrong Input. Exiting to prevent SNAFUs...\n"; exit;}
		}
	}
}
## subroutines
sub tab{
	if ($x >= 8){$tab = "\t";}
	else{$tab = "\t\t";}
}
sub threed{
	if ($d3){
		if (defined $d3{$col[0]}){foreach (@{$d3{$col[0]}}){print "3D.\tGESAMT:\t\t"."$_"."\n";}}
		else{print "3D.\tGESAMT:\t\t"."NA\t\tno match found"."\n";}
	}
}