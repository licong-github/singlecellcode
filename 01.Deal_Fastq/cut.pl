#!/usr/bin/perl -w
#
my @all=<$ARGV[0]/*\/*_1.fq>;
my($small,$least,$line);
for(@all){
	my @a=stat($_);
	my $size=$a[7];
	$small ||="$_";
	$least ||="$size";
	$small=($size < $least)?"$_":"$small";
	$least=($size < $least)?"$size":"$least";
}
open IN,"$small";
print "$small\n\n";
while(<IN>){
	$line++;
}
close IN;
open IN1,"$ARGV[1]";
open IN2,"$ARGV[2]";
my $fq1=$ARGV[1];
my $fq2=$ARGV[2];
$fq1=~s/fq$/fastq/;
$fq2=~s/fq$/fastq/;
print "$fq1\n$fq2\n";
open OUT1,">$fq1";
open OUT2,">$fq2";
my ($a,$b);
for(1..$line){
	$a=<IN1>;
	$b=<IN2>;
	print OUT1 "$a";
	print OUT2 "$b";
}
close IN1;close IN2;close OUT1;close OUT2;
