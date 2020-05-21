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

`mkdir -p $outdir/shell/reads_counts`;
`mkdir -p $outdir/list`;
open LIST,">$outdir/list/reads_counts.list";
open DEP,">$outdir/list/reads_counts.monitor";
open IN,"$list"; 
while(<IN>){
	next if(/^#/);chomp;
	my @a=split /\t/,$_;
	`mkdir -p $outdir/process/reads_counts/$a[0]`;
	open OUT,">$outdir/shell/reads_counts/reads_counts_$a[0].sh";
	my $abs=abs_path("$outdir/process/reads_counts/$a[0]");
	my $shell_path=abs_path("$outdir/shell/reads_counts");
	print OUT "cd $abs\necho -e `date` && \\\n$conf{'featureCounts'} $conf{'featureCounts_opts'} -a $conf{'gtf'} -o $a[0].featureCounts.txt $a[1] && \\\ncut -f 1,7 $a[0].featureCounts.txt |grep -v '^#'|grep -v Geneid >$a[0].Counts.xls  && \\\necho `date` && \\\necho 'DONE' >>$shell_path/reads_counts_$a[0].sh.sign\n";
	print LIST "$a[0]\t$abs\t$shell_path/reads_counts_$a[0].sh\n";
		
	if($a[-1]=~/\.sh$/){
		print DEP "$a[-1]\t$shell_path/reads_counts_$a[0].sh\n";
	}else{
		print DEP "$shell_path/reads_counts_$a[0].sh\n";
	}
	close OUT;
	print DEP "$shell_path/reads_counts_$a[0].sh\t$shell_path/sum.sh\n";
}
open OUT,">$outdir/shell/reads_counts/sum.sh\n";
print OUT "cd $outdir/process/reads_counts \necho -e `date` && \\\nperl $Bin/sum.pl $conf{'gtf'} $outdir/process/reads_counts >all.reads.xls && \\\necho `date` && \\\necho 'DONE' >>$outdir/shell/reads_counts/sum.sh.sign\n";
print LIST "SUMMARY\t$outdir/process/reads_counts/all.reads.xls\t$outdir/shell/reads_counts/sum.sh\n";
close OUT;
close IN;close LIST;close DEP;
print STDERR "DONE\n";
