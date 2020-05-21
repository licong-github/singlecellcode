#!/usr/bin/perl -w
#
open IN,"$ARGV[0]"; #wellcode
while(<IN>){
	chomp;
	my @a=split /\s+/,$_;
	push @wellcode,$a[0];
}
close IN;

open IN,"$ARGV[1]"; #exp
open OUT,">$ARGV[2]"; #out
chomp(my $h=<IN>);
my @h=split /\t+/,$h;
my @gene=();
my %ha=();
while(<IN>){
	chomp;
	my @a=split /\t+/,$_; 
	push @gene,$a[0];
	print OUT "\t$a[0]";
	for(1..$#h){
		$ha{$h[$_]}{$a[0]}=$a[$_];
	}
}
close IN;
print OUT "\n";
foreach my $well(@wellcode){
	print OUT "$well";
	foreach my $g(@gene){
		print OUT "\t$ha{$well}{$g}";
	}
	print OUT "\n";
}
close OUT;

