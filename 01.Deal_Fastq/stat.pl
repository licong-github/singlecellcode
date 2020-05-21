#!/usr/bin/perl
#
my @all=<$ARGV[0]/*\/*stats.xls>;
open OUT,">$ARGV[1]";
open OUT2,">$ARGV[2]";
print OUT "sample\told_wellcode_percent\tnew_wellcode_percent\n";
print OUT2 "sample\tPOS\tREV\n";
foreach my $s(@all){
	my ($name)=$s=~/.*\/(\S+).stats.xls/;
	open IN,$s;
	print OUT "$name";
	print OUT2 "$name";
	while(<IN>){
		chomp;
		if(/^wellcode_percent\s+(\S+)/){
			print OUT "\t$1";
		}
		if(/^POS:\s+(\S+)/){
			print OUT2 "\t$1";
		}
		if(/^REV:\s+(\S+)/){
			print OUT2 "\t$1";
		}
	}
	print OUT "\n";
	print OUT2 "\n";
	close IN;
}
close OUT;
