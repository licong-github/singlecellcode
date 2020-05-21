#!/usr/bin/perl -w
#
my $sam=$ARGV[0];
my %uniq;
open OUT,">$ARGV[1]";
print OUT "3'Distance\tInsert\n";
open IN,"$sam";
while(<IN>){
	next if(/^@/);
	my @a=split /\t/,$_;
	my $i=abs($a[7]-$a[3]);
	my $out="$a[0]\t$a[2]\t$a[3]\t$a[7]\t$i";
	next if(not $a[6] eq '=');
	next if($uniq{$out});
	my $a8=abs($a[8]);
	my $diff=$a8-$i;
	next if($diff >150);
	print OUT "$i\t$a8\n";
	$uniq{$out}=1;<IN>;
}
close IN;
close OUT;

