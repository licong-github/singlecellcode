#!/usr/bin/perl -w
#
my @all=split /,/,$ARGV[0];
open OUT,">$ARGV[1]";
print OUT "3'Distance\tInsert\n";
foreach my $s(@all){
	open IN,"$s";<IN>;
	while(<IN>){
		print OUT $_;
	}
	close IN;
}
close OUT;
