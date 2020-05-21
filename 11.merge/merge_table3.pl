#!/usr/bin/perl -w
#

my @all=split /,/,$ARGV[0];
open OUT,">$ARGV[1]";
my %ha;
print OUT "Gene\tReads\tUMI\tLength\tGC\n";
foreach my $s(@all){
	open IN,"$s";<IN>;
	while(<IN>){
		chomp;
		my @a=split /\t/,$_;
		$ha{$a[0]}{'reads'}=($ha{$a[0]}{'reads'})?$ha{$a[0]}{'reads'}+$a[1]:$a[1];
		$ha{$a[0]}{'umi'}=($ha{$a[0]}{'umi'})?$ha{$a[0]}{'umi'}+$a[2]:$a[1];
		$ha{$a[0]}{'l'}=$a[3];
		$ha{$a[0]}{'gc'}=$a[4];
	}
	close IN;

}
for(keys %ha){
	print OUT "$_\t$ha{$_}{'reads'}\t$ha{$_}{'umi'}\t$ha{$_}{'l'}\t$ha{$_}{'gc'}\n";
}
