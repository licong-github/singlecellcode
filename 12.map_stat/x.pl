#!/usr/bin/perl -w 
use FindBin '$Bin';
use Getopt::Long;
use Cwd 'abs_path';

my @all=<$ARGV[0]/*\/rnaseq_qc_results.txt>;

open OUT,">map_stat_exonic.xls";
print OUT "sample\tMapped.exonic\tMapped.non.exonic\tUnmapped\n";
foreach my $s(@all){
	my ($name)=$s=~/.*\/(\S+)\/rnaseq_qc_results.txt/;
	my %ha=();
	open IN,$s;
	while(<IN>){
		chomp;
		$_=~s/,//g;
		$_=~s/^\s+//g;
		$_=~s/\s+$//g;
		if(/=/){
			my @a=split /\s+=\s+/,$_;
			my @b=split /\s+/,$a[1];
			$a[1]=$b[0];
			$ha{$a[0]}=$a[1];
		}
	}
	close IN;
#	print "$ha{'reads aligned'}\t$ha{'exonic'}\n";
	my $noexon=$ha{'reads aligned'}-$ha{'exonic'};
#	my $nomap=$ha{'total alignments'}-$ha{'reads aligned'};
	my $nomap=$ha{'not aligned'};
	print OUT "$name\t$ha{'exonic'}\t$noexon\t$nomap\n";
}
`cp $Bin/exonic_bar.R . && $ARGV[1] exonic_bar.R`;
