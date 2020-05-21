#!/usr/bin/perl -w 
use FindBin '$Bin';
use Getopt::Long;
use Cwd 'abs_path';

my @all=<$ARGV[0]/*\/*Log.final.out>;

open OUT,">map_stat_uniqe.xls";
print OUT "sample\tUniquely.Mapped\tMulti.Mapped\tUnmapped\n";
foreach my $s(@all){
	my ($name)=$s=~/.*\/(\S+)\/.*Log.final.out/;
	my %ha=();
	open IN,$s;
	while(<IN>){
		chomp;
		if(/Number of input reads \|\s+(\d+)$/){
			$ha{'all'}=$1;
		}
		if(/Uniquely mapped reads number \|\s+(\d+)$/){
			$ha{'uniq'}=$1;
		}
		if(/Number of reads mapped to multiple loci \|\s+(\d+)$/){
			$ha{'muti1'}=$1;
		}
		if(/Number of reads mapped to too many loci \|\s+(\d+)$/){
			$ha{'muti2'}=$1;
		}
	}
	close IN;
	my $nomap=$ha{'all'}-$ha{'uniq'}-$ha{'muti1'}-$ha{'muti2'};
	my $mutimap=$ha{'muti1'}+$ha{'muti2'};
	print OUT "$name\t$ha{'uniq'}\t$mutimap\t$nomap\n";
}
`cp $Bin/uniqe_bar.R . && $ARGV[1] uniqe_bar.R`;
