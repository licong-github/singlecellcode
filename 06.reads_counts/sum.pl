#!/usr/bin/perl -w
my (%ha,%n,%t);
#open IN,"/hdd/database/10X/refdata-cellranger-hg19-1.2.0/genes/genes.gtf";
open IN,"$ARGV[0]"; #gtf
while(<IN>){
	if(/gene_id "(\S+)";.*gene_name "(\S+)";/){
		$n{$1}=$2;
	}
	if(/gene_id "(\S+)";.*transcript_id "(\S+)";/){
		$t{$1}=($t{$1})?"$t{$1},$2":"$2";
	}
}
close IN;

my @all=<$ARGV[1]/*/*Counts.xls>;
my @arry;
my %number;
print "geneid\tsymbol";
foreach my $sample(@all){
	my ($n)=$sample=~/.*\/(\S+).Counts.xls/;
	push @arry,$n;
	print "\t$n";
	open IN,"$sample";
	while(<IN>){
		chomp;
		my @a=split /\t/,$_;
		$ha{$a[0]}{$n}=$a[1];
		$number{$n}++ unless($a[1] == 0);
	}
	close IN;
}
print "\n";
foreach my $g(keys %ha){
	print "$g\t$n{$g}";
	for(@arry){
		print "\t$ha{$g}{$_}";
	}
	print "\n";
}
open OUT,">gene_number.xls";
print OUT "sample\tgene_number\n";
foreach my $s(sort keys %number){
	print OUT "$s\t$number{$s}\n";
}
close OUT;
