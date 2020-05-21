#!/usr/bin/perl -w
###################################  
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

`mkdir -p $outdir/shell/Deal_Fastq`;
`mkdir -p $outdir/list`;
open LIST,">$outdir/list/Deal_Fastq.list";
open DEP,">$outdir/list/Deal_Fastq.monitor";
open IN,"$list"; 
while(<IN>){
	next if(/^#/);chomp;
	my @a=split /\t/,$_;
	`mkdir -p $outdir/process/Deal_Fastq/$a[0]`;
	open OUT,">$outdir/shell/Deal_Fastq/Deal_Fastq_$a[0].sh";
	my $abs=abs_path("$outdir/process/Deal_Fastq/$a[0]");
	my $shell_path=abs_path("$outdir/shell/Deal_Fastq");
	print OUT "cd $abs\necho -e `date` && \\\nperl $Bin/fastq_deal.pl $conf{'wellcode_list'} $a[1] $a[2] $a[0] $conf{'umi_length'} $conf{'wellcode_length'}  && \\\necho `date` && \\\necho 'DONE' >>$shell_path/Deal_Fastq_$a[0].sh.sign\n";
	if( $conf{"cut"} && $conf{"cut"} eq "T"){
		open OUT2,">$outdir/shell/Deal_Fastq/Cut_$a[0].sh";
		print OUT2 "cd $abs\necho -e `date` && \\\nperl $Bin/cut.pl $outdir/process/Deal_Fastq $abs/$a[0]_1.fq $abs/$a[0]_2.fq  && \\\necho `date` && \\\necho 'DONE' >>$shell_path/Cut_$a[0].sh.sign\n";
		close OUT2;
		print LIST "$a[0]\t$abs/$a[0]_1.fastq\t$abs/$a[0]_2.fastq\t$shell_path/Cut_$a[0].sh\n";
		print DEP "$shell_path/Deal_Fastq_$a[0].sh\t$shell_path/Cut_$a[0].sh\n";
	}else{
                print LIST "$a[0]\t$abs/$a[0]_1.fq\t$abs/$a[0]_2.fq\t$shell_path/Deal_Fastq_$a[0].sh\n";

	}
	if($a[-1]=~/\.sh$/){
		print DEP "$a[-1]\t$shell_path/Deal_Fastq_$a[0].sh\n";
	}else{
		print DEP "$shell_path/Deal_Fastq_$a[0].sh\n";
	}
	close OUT;
	print DEP "$shell_path/Deal_Fastq_$a[0].sh\t$shell_path/sum.sh\n";
}
open OUT,">$outdir/shell/Deal_Fastq/sum.sh";
print OUT "cd $outdir/process/Deal_Fastq\necho -e `date` && \\\nperl $Bin/stat.pl $outdir/process/Deal_Fastq wellcode_percent.xls pos_rev.xls && \\\ncp wellcode_percent.xls pos_rev.xls $outdir/result && \\\necho `date` && \\\necho 'DONE' >>$outdir/shell/Deal_Fastq/sum.sh.sign\n";
close OUT;
close IN;close LIST;close DEP;

print STDERR "DONE\n";
