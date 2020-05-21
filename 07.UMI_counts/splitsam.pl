#!/usr/bin/perl -w

open IN,"$ARGV[0]"; #bacode
while(<IN>){
	chomp();
	next if(/^#/);
	push @arry,$_;
}
close IN;

open IN,"$ARGV[1]";
for(@arry){
	open $_,">$_.sam";
}
while(<IN>){
	next if(/^@/);
	my @a=split /\t/,$_,2;
	my @b=split /:/,$a[0];
	my $out = $b[-2];
	print $out "$_";
}
