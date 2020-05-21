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

`mkdir -p $outdir/shell/merge`;
`mkdir -p $outdir/list`;
`mkdir -p $outdir/result/merge`;
open LIST,">$outdir/list/merge.list";
open DEP,">$outdir/list/merge.monitor";
my @plan=split /\s+/,$conf{'merge_plan'};
foreach my $p(@plan){
	my($t1,$t2_1,$t2_2,$t3,$t4)=();
	my($name,$samples)=$p=~/(\S+):(\S+)/;
	my @sample=split /,/,$samples;
	`mkdir -p $outdir/process/merge/$name`;
	my $abs=abs_path("$outdir/process/merge/$name");
	my $shell_path=abs_path("$outdir/shell/merge");
	open OUT,">$outdir/shell/merge/merge_$name.sh";
	for(@sample){
		$t1 .= "$outdir/process/junyixing/$_/$_.table1.xls,";
		$t2_1 .= "$outdir/process/UMI_counts/4.deal_exp/$_/$_.table2-1.xls,";
		$t2_2 .= "$outdir/process/UMI_counts/4.deal_exp/$_/$_.table2-2.xls,";
		$t3 .= "$outdir/process/table3/$_/$_.table3.xls,";
		$t4 .= "$outdir/process/table4/$_/$_.table4.xls,";
		print DEP "$outdir/shell/junyixing/junyixing_$_.sh\t$outdir/shell/merge/merge_$name.sh\n";		
		print DEP "$outdir/shell/UMI_counts/4.deal_exp/UMI_deal_exp_$_.sh\t$outdir/shell/merge/merge_$name.sh\n";		
		print DEP "$outdir/shell/table3/table3_$_.sh\t$outdir/shell/merge/merge_$name.sh\n";		
		print DEP "$outdir/shell/table4/table4_$_.sh\t$outdir/shell/merge/merge_$name.sh\n";		
	}
	$t1=~s/,$//;
	$t2_1=~s/,$//;
	$t2_2=~s/,$//;
	$t3=~s/,$//;
	$t4=~s/,$//;
	print OUT "cd $abs\necho -e `date` && \\\n";
	print OUT "perl $Bin/merge_table1.pl $conf{'wellcode_list'} $t1 $name.table1.xls && \\\n";
	print OUT "perl $Bin/merge_table2.pl $t2_1  $name.table2-1.xls && \\\n";
	print OUT "perl $Bin/merge_table2.pl $t2_2  $name.table2-2.xls && \\\n";
	print OUT "perl $Bin/merge_table3.pl $t3  $name.table3.xls && \\\n";
	print OUT "perl $Bin/merge_table4.pl $t4  $name.table4.xls && \\\n";
	print OUT "cp -r $abs $outdir/result/merge && \\\n";
	print OUT "echo `date` && \\\necho 'DONE' >>$shell_path/merge_$name.sh.sign\n";
	close OUT;
}
close LIST;close DEP;
print STDERR "DONE\n";
