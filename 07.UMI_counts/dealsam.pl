#!/usr/bin/perl -w

my %ha;
open IN,$ARGV[0];
open OUT,">$ARGV[1]";
my @a;
while(<IN>){
	if(/^@/){
		print OUT $_;
		next;
	}
	@a=split /\t+/,$_,11;
	my @b=split /:/,$a[0];
	my $bu="$b[-2]-$b[-1]";
	if(exists $ha{"$bu-$a[9]"}){
		next;
	}else{
		$ha{"$bu-$a[9]"}="";
		print OUT $_;
	}

}
