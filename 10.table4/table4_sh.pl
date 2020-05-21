#!/usr/bin/perl -w
###################################  
##  Author : licong  
##  Version : 1.0(2018/01/05)  
##  E-mail : lc@xkybio.com  
####################################
use FindBin '$Bin';
use Getopt::Long;
use Cwd 'abs_path';

my ($list,$out,$config,%conf);
GetOptions(
	"c:s" => \$config,
	"l:s" => \$list,
	"o:s" => \$outdir
);
$outdir ||=".";
$config ||="$Bin/../RNAseq.conf";
open CONF,"$config";
while(<CONF>){
	next if (/^\s*$/ || /^\s*#/ || !/=/);
	chomp; s/^([^#]+)#.*$/$1/;
	my ($key,$value) = split /=/,$_,2;
        $key =~ s/^\s*(.*?)\s*$/$1/;
	$value =~ s/^\s*(.*?)\s*$/$1/;
	next if ($value =~ /^\s*$/);
	$conf{$key} = $value;
}
close CONF;

die "erro: list or conf file not exists !!\nusege:\nperl $0 -c RNAseq.conf -l rawdata.list -o result\n" unless($list && $config && -f $list && -f $config); 

`mkdir -p $outdir/shell/table4`;
`mkdir -p $outdir/list`;
open LIST,">$outdir/list/table4.list";
open DEP,">$outdir/list/table4.monitor";
open IN,"$list"; 
while(<IN>){
	next if(/^#/);
	next if(/^SUMMARY/);
	chomp;
	my @a=split /\t/,$_;
	`mkdir -p $outdir/process/table4/$a[0]`;
	open OUT,">$outdir/shell/table4/table4_$a[0].sh";
	my $abs=abs_path("$outdir/process/table4/$a[0]");
	my $shell_path=abs_path("$outdir/shell/table4");
	print OUT "cd $abs\necho -e `date` && \\\nperl $Bin/x.pl $a[1] $a[0].table4.xls && \\\necho `date` && \\\n";
#	print OUT "perl $Bin/x.pl $abs/../../UMI_counts/3.exp/$a[0]/gene_number.xls $a[0].xls $a[0].table1.xls && \\\necho `date` && \\\n";
	print OUT "cp $abs/$a[0].table4.xls $outdir/result/$a[0] && \\\n";
	print OUT "echo 'DONE' >>$shell_path/table4_$a[0].sh.sign\n";
	print LIST "$a[0]\t$abs\t$shell_path/table4_$a[0].sh\n";
		
	print DEP "$a[-1]\t$shell_path/table4_$a[0].sh\n";
	close OUT;
}
close IN;close LIST;close DEP;
print STDERR "DONE\n";
