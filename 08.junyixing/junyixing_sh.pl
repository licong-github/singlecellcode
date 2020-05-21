#!/usr/bin/perl -w
###################################  
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

`mkdir -p $outdir/shell/junyixing`;
`mkdir -p $outdir/list`;
open LIST,">$outdir/list/junyixing.list";
open DEP,">$outdir/list/junyixing.monitor";
open IN,"$list"; 
while(<IN>){
	next if(/^#/);chomp;
	my @a=split /\t/,$_;
	`mkdir -p $outdir/result/$a[0]`;
	`mkdir -p $outdir/process/junyixing/$a[0]`;
	open OUT,">$outdir/shell/junyixing/junyixing_$a[0].sh";
	my $abs=abs_path("$outdir/process/junyixing/$a[0]");
	my $shell_path=abs_path("$outdir/shell/junyixing");
	print OUT "cd $abs\necho -e `date` && \\\nperl $Bin/junyixing.pl $a[1] $a[0].xls $conf{'wellcode_list'} $conf{'gtf'} && \\\n";
	print OUT "perl $Bin/x.pl $abs/../../UMI_counts/3.exp/$a[0]/gene_number.xls $a[0].xls $a[0].table1.xls && \\\necho `date` && \\\n";
	print OUT "cp $a[0].table1.xls $outdir/result/$a[0] && \\\n";
	print OUT "echo 'DONE' >>$shell_path/junyixing_$a[0].sh.sign\n";
	print LIST "$a[0]\t$abs\t$shell_path/junyixing_$a[0].sh\n";
		
	print DEP "$a[-1]\t$shell_path/junyixing_$a[0].sh\n";
	print DEP "$outdir/shell/UMI_counts/3.exp/UMI_exp_$a[0].sh\t$shell_path/junyixing_$a[0].sh\n";
	close OUT;
}
close IN;close LIST;close DEP;
print STDERR "DONE\n";
