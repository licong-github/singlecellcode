#!/usr/bin/perl -w
use FindBin '$Bin';
use Getopt::Long;
use Cwd 'abs_path';

my @a=<$ARGV[0]/*sam>;

my $path2;
foreach my $sam(@a){
	my($path,$name)=$sam=~/(.*)\/(\S+).sam/;
	system("cd $path && $ARGV[1] -T 8 -t exon -g gene_id -a $ARGV[2] -o $name.featureCounts.txt  $sam && cut -f 1,7 $name.featureCounts.txt |grep -v '^#'|grep -v Geneid >$name.Counts.xls");
	$path2=$path;
}
system("cd $path2 && perl $Bin/sum.pl $ARGV[2] $path2 >all.umi.xls");

