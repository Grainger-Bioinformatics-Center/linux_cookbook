#!/usr/bin/perl
## Pombert Lab,Yukun, IIT, 2020
my $name = 'get_queries.pl';
my $version = '0.1';

use strict; use warnings;

my $usage = <<"OPTIONS";

NAME		$name
VERSION		$version
SYNOPSIS	Generates simple lists of sequences present in FASTA files
USAGE		get_queries.pl *.fasta
OPTIONS
die "$usage\n" unless @ARGV;

while (my $fasta = shift@ARGV){
	open IN, "<$fasta";
	$fasta =~ s/.fasta//; $fasta =~ s/.fsa//;
	open OUT, ">$fasta.queries";
	while (my $line = <IN>){
		chomp $line;
		if ($line =~ /^>(\S+)/){print OUT "$1\n";}
	}
} 