#!/usr/bin/perl -w
use FindBin '$Bin';
#
my $gc ||="$Bin/../99.other/gene_GC.txt";


my (%lgc,%r,%u);
open IN,"$gc";<IN>;
while(<IN>){
	chomp();
	my @a=split /\t/,$_;
	$lgc{$a[0]}="$a[1]\t$a[-1]";
}
close IN;

my $f=$ARGV[0];
open SR,"$f";
while(<SR>){
	chomp();
	my @a=split /\t/,$_;
	$r{$a[0]}=$a[1];
}
close SR;
open SU,"$ARGV[1]";
while(<SU>){
	chomp();
	my @a=split /\t/,$_;
	$u{$a[0]}=$a[1];
}
open OUT,">$ARGV[2]";
print OUT "Gene\tReads\tUMI\tLength\tGC\n";
for(keys %lgc){
	if($r{$_} && $u{$_}){
		print OUT "$_\t$r{$_}\t$u{$_}\t$lgc{$_}\n";
	}
}
close OUT;
