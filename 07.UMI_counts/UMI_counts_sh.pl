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

`mkdir -p $outdir/shell/UMI_counts/{1.dealsam,2.splitsam,3.exp,4.deal_exp}`;
`mkdir -p $outdir/list`;
open LIST,">$outdir/list/UMI_counts.list";
open DEP,">$outdir/list/UMI_counts.monitor";
open IN,"$list"; 
while(<IN>){
	next if(/^#/);chomp;
	my @a=split /\t/,$_;
	`mkdir -p $outdir/process/UMI_counts/1.dealsam/$a[0]`;
	my $shell_path=abs_path("$outdir/shell/UMI_counts");
	open OUT,">$shell_path/1.dealsam/UMI_dealsam_$a[0].sh";
	my $abs=abs_path("$outdir/process/UMI_counts/1.dealsam/$a[0]");
	print OUT "cd $abs\necho -e `date` && \\\nperl $Bin/dealsam.pl $a[1] $a[0].sam && \\\necho `date` && \\\necho 'DONE' >>$shell_path/1.dealsam/UMI_dealsam_$a[0].sh.sign\n";
	close OUT;
	print DEP "$a[-1]\t$shell_path/1.dealsam/UMI_dealsam_$a[0].sh\n";
	open OUT,">$shell_path/1.dealsam/UMI_dealsam_exp_$a[0].sh";
	print OUT "cd $abs\necho -e `date` && \\\n$conf{'featureCounts'} $conf{'featureCounts_opts'} -a $conf{'gtf'} -o $a[0].featureCounts.txt $a[0].sam && \\\ncut -f 1,7 $a[0].featureCounts.txt |grep -v '^#'|grep -v Geneid >$a[0].Counts.xls && \\\necho `date` && \\\necho 'DONE' >>$shell_path/1.dealsam/UMI_dealsam_exp_$a[0].sh.sign\n";
	close OUT;
	print DEP "$shell_path/1.dealsam/UMI_dealsam_$a[0].sh\t$shell_path/1.dealsam/UMI_dealsam_exp_$a[0].sh\n";

	`mkdir -p $outdir/process/UMI_counts/2.splitsam/$a[0]`;
	open OUT,">$shell_path/2.splitsam/UMI_splitsam_$a[0].sh";
	$abs=abs_path("$outdir/process/UMI_counts/2.splitsam/$a[0]");
	print OUT "cd $abs\necho -e `date` && \\\nperl $Bin/splitsam.pl $conf{'wellcode_list'} $outdir/process/UMI_counts/1.dealsam/$a[0]/$a[0].sam && \\\necho `date` && \\\necho 'DONE' >>$shell_path/2.splitsam/UMI_splitsam_$a[0].sh.sign\n";
	close OUT;
	print DEP "$shell_path/1.dealsam/UMI_dealsam_$a[0].sh\t$shell_path/2.splitsam/UMI_splitsam_$a[0].sh\n";

	`mkdir -p $outdir/process/UMI_counts/3.exp/$a[0]`;
	open OUT,">$shell_path/3.exp/UMI_exp_$a[0].sh";
	$abs=abs_path("$outdir/process/UMI_counts/3.exp/$a[0]");
	print OUT "cd $abs\necho -e `date` && \\\nperl $Bin/all.pl $outdir/process/UMI_counts/2.splitsam/$a[0] $conf{'featureCounts'} $conf{'gtf'} && \\\n";
	print OUT "cp $outdir/process/UMI_counts/2.splitsam/$a[0]/*xls $abs && rm $abs/*Counts.xls && \\\n";
	print OUT "cp $outdir/process/UMI_counts/3.exp/$a[0]/exp.xls $outdir/process/UMI_counts/3.exp/$a[0]/$a[0].table2-1.xls && \\\n";
	print OUT "cp $outdir/process/UMI_counts/3.exp/$a[0]/exp_nomalized.xls $outdir/process/UMI_counts/3.exp/$a[0]/$a[0].table2-2.xls && \\\n";
	print OUT "cp $outdir/process/UMI_counts/3.exp/$a[0]/$a[0].table2*xls $outdir/result/$a[0] && \\\n";
	print OUT "echo `date` && \\\necho 'DONE' >>$shell_path/3.exp/UMI_exp_$a[0].sh.sign\n";
	close OUT;
	print DEP "$shell_path/2.splitsam/UMI_splitsam_$a[0].sh\t$shell_path/3.exp/UMI_exp_$a[0].sh\n";

	`mkdir -p $outdir/process/UMI_counts/4.deal_exp/$a[0]`;
	open OUT,">$shell_path/4.deal_exp/UMI_deal_exp_$a[0].sh";
	$abs=abs_path("$outdir/process/UMI_counts/4.deal_exp/$a[0]");
	print OUT "cd $abs\necho -e `date` && \\\n";
	print OUT "perl $Bin/dealexp.pl $conf{'wellcode_list'} $outdir/process/UMI_counts/3.exp/$a[0]/exp.xls $a[0].table2-1.xls && \\\n";
	print OUT "perl $Bin/dealexp.pl $conf{'wellcode_list'} $outdir/process/UMI_counts/3.exp/$a[0]/exp_nomalized.xls $a[0].table2-2.xls && \\\n";
	print OUT "cp $outdir/process/UMI_counts/2.splitsam/$a[0]/*xls $abs && rm $abs/*Counts.xls && \\\n";
#	print OUT "cp $abs/$a[0].table2*xls $outdir/result/$a[0] && \\\n";
	print OUT "echo `date` && \\\necho 'DONE' >>$shell_path/4.deal_exp/UMI_deal_exp_$a[0].sh.sign\n";
	close OUT;
	print DEP "$shell_path/3.exp/UMI_exp_$a[0].sh\t$shell_path/4.deal_exp/UMI_deal_exp_$a[0].sh\n";
	

	print LIST "$a[0]\t$abs\t$shell_path/3.exp/UMI_exp_$a[0].sh\n";
}
#open OUT,">$outdir/shell/UMI_counts/sum.sh\n";
#print OUT "cd $outdir/process/UMI_counts \necho -e `date` && \\\nperl $Bin/sum.pl $conf{'gtf'} $outdir/process/UMI_counts >all.reads.xls && \\\necho `date` && \\\necho 'DONE' >>$outdir/shell/UMI_counts/sum.sh.sign\n";
#print LIST "SUMMARY\t$outdir/process/UMI_counts/all.reads.xls\t$outdir/shell/UMI_counts/sum.sh\n";
#close OUT;
close IN;close LIST;close DEP;
print STDERR "DONE\n";
