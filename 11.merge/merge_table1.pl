#!/usr/bin/perl -w
#
open IN,"$ARGV[0]";
while(<IN>){
	chomp;
	push @well_code,$_;
}
close IN;

my @all=split /,/,$ARGV[1];
open OUT,">$ARGV[2]";
print OUT "Id\tsample_index\twellcode\ttotal_umi_kinds\tmapped_umi_kinds\ttotal_reads\tmapped_reads\texon_mapped_reads\tno_exon_mapped_reads\tunique-maped_reads\tmuti_mapped_reads\tun_maped_reads\tgene_number\tgene number(UMI>1)\tgene number(UMI>5)\tgene number(UMI>10)\tgene number(UMI>100)\n";
my $n=0;
my $n2=0;
foreach my $s(@all){
$n2++;
my %ha=();
open IN,"$s";<IN>;
while(<IN>){
	$n++;
	my @a=split /\t/,$_,2;
	$ha{$a[0]}{'all'}=$a[1];
	$ha{$a[0]}{'id'}=$n;
}
close IN;
for(@well_code){
	print OUT "$ha{$_}{'id'}\t$n2\t$_\t$ha{$_}{'all'}";
}

}
