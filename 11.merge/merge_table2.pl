#!/usr/bin/perl -w
#

my @all=split /,/,$ARGV[0];
open OUT,">$ARGV[1]";
my $n=0;
my(%g,%ha,@well);
foreach my $s(@all){
	open IN,"$s" or die "$s not exists\n";
	chomp(my $h=<IN>);
	my @h=split /\t+/,$h;
	for(1..$#h){
		$g{$h[$_]}=1;
	}
	while(<IN>){
		chomp;
		$n++;
		my @a=split /\t/,$_;
		for(1..$#a){
			$ha{"$a[0]_$n"}{$h[$_]}=$a[$_];
		}
		push @well,"$a[0]_$n";
	}
	close IN;

}
my @g=keys %g;
=a
my $head=join("\t",@g);
print OUT "\t$head\n";
foreach my $w(@well){
	print OUT "$w";
	for(@g){
		$ha{$w}{$_} ||=0;
		print OUT "\t$ha{$w}{$_}";
	}
	print OUT "\n";
}
=cut

my $head=join("\t",@well);
print OUT "\t$head\n";
foreach my $g(@g){
        print OUT "$g";
        for(@well){
                $ha{$_}{$g} ||=0;
                print OUT "\t$ha{$_}{$g}";
        }
        print OUT "\n";
}

close OUT;

