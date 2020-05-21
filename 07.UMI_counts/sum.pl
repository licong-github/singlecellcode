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

#my @all=<$ARGV[0]/*Counts.xls>;
my @all=<$ARGV[1]/*Counts.xls>;
my @arry;
my %number;
my %number2;
my %number3;
my %number4;
my %number5;
my %number10;

print "geneid\tsymbol";
open OUT2,">exp.xls";
open OUT3,">exp_nomalized.xls";
my %cell;
foreach my $sample(@all){
	my ($n)=$sample=~/.*\/(\S+).Counts.xls/;
	push @arry,$n;
	print "\t$n";
	print OUT2 "\t$n";
	print OUT3 "\t$n";
	open IN,"$sample";
	while(<IN>){
		chomp;
		my @a=split /\t/,$_;
		$ha{$a[0]}{$n}=$a[1];
		$cell{$n}{'sum'} += $a[1];
		$cell{$n}{'ng'}++;
		$number{$n}++ unless($a[1] == 0);
		$number1{$n}++ if($a[1] > 1);
		$number5{$n}++ if($a[1] > 5);
		$number10{$n}++ if($a[1] > 10);
		$number100{$n}++ if($a[1] > 100);
		$number10{$n}++ if($a[1] > 10);
	}
	close IN;
}
print "\n";
print OUT2 "\n";
print OUT3 "\n";
my %ha2;
foreach my $g(keys %ha){
	print "$g\t$n{$g}";
	for(@arry){
		print "\t$ha{$g}{$_}";
	}
	print "\n";
	next if($ha2{$n{$g}});
	print  OUT2 "$n{$g}";
	print  OUT3 "$n{$g}";
	for(@arry){
		print OUT2 "\t$ha{$g}{$_}";
		my $o=0;
		if($cell{$_}{'sum'}){
			$o=$ha{$g}{$_}/$cell{$_}{'sum'}*1000000;
		}
		$o=log($o+1);
		unless($o==0){$o = sprintf("%.2f",$o)};
		print OUT3 "\t$o";
	}
	print OUT2 "\n";
	print OUT3 "\n";
	$ha2{$n{$g}}=1;
}
open OUT,">gene_number.xls";
print OUT "sample\tgene_number\tgene number（UMI>1）\tgene number（UMI>5）\tgene number（UMI>10）\tgene number（UMI>100）\n";
foreach my $s(sort keys %number){
	$number1{$s} ||=0;
	$number5{$s} ||=0;
	$number10{$s} ||=0;
	$number100{$s} ||=0;
	print OUT "$s\t$number{$s}\t$number1{$s}\t$number5{$s}\t$number10{$s}\t$number100{$s}\n";
}
close OUT;
