#!/usr/bin/perl -w
# perl $0 gene_number.xls junyixing,xls  sample.table1.xls

open IN1,"$ARGV[0]";
chomp(my $h=<IN1>);
my @h=split /\t/,$h,2;
my %ha=();
while(<IN1>){
	chomp;
	my @a=split /\t/,$_,2;
	$ha{$a[0]}=$a[1];
}
close IN1;
open IN,"$ARGV[1]";
open OUT,">$ARGV[2]";
chomp(my $head=<IN>);
#print OUT "$head\t$h[1]\tMapping_rate(%)\texon_Mapping_rate(%)\n";
print OUT "$head\t$h[1]\n";
while(<IN>){
	chomp;
	my @a=split /\t/,$_;
	my $g=($ha{$a[0]})?"$ha{$a[0]}":"0\t0\t0\t0\t0";
#	my $map_rate=$a[3]/$a[1]*100;
#	$map_rate=sprintf("%.2f",$map_rate);
#	my $exon_map_rate=$a[4]/$a[1]*100;
#	$exon_map_rate=sprintf("%.2f",$exon_map_rate);
#	print OUT "$_\t$g\t$map_rate\t$exon_map_rate\n";
	print OUT "$_\t$g\n";
}
close IN;close OUT;

	
