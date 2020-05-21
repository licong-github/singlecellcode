#!/usr/bin/perl -w
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

`mkdir -p $outdir/shell/Filter`;
`mkdir -p $outdir/list`;
open LIST,">$outdir/list/Filter.list";
open DEP,">$outdir/list/Filter.monitor";
open IN,"$list"; 
while(<IN>){
	next if(/^#/);chomp;
	my @a=split /\t/,$_;
	`mkdir -p $outdir/process/Filter/$a[0]`;
	open OUT,">$outdir/shell/Filter/Filter_fastp_$a[0].sh";
	my $abs=abs_path("$outdir/process/Filter/$a[0]");
	my $shell_path=abs_path("$outdir/shell/Filter");
	if(@a > 2 && $a[2]!~/\.sh$/){
		print OUT "cd $abs\necho -e `date` && \\\n$conf{'fastp'} -i $a[1] -o $abs/$a[0]_1.fq.gz -I $a[2] -O $abs/$a[0]_2.fq.gz -h $a[0].fastp.html -j $a[0].fastp.json $conf{'fastp_opts'} && \\\necho `date` && \\\nsed -i 's#$a[1]#$a[0].fq.gz#g' $a[0].fastp.json && \\\necho 'DONE' >>$shell_path/Filter_fastp_$a[0].sh.sign\n";
		print LIST "$a[0]\t$abs/$a[0]_1.fq.gz\t$abs/$a[0]_2.fq.gz\t$shell_path/Filter_fastp_$a[0].sh\n";
	}else{
		print OUT "cd $abs\necho -e `date` && \\\n$conf{'fastp'} -i $a[1] -o $abs/$a[0]_1.fq.gz -h $a[0].fastp.html -j $a[0].fastp.json $conf{'fastp_opts'} && \\\nsed -i 's#$a[1]#$a[0].fq.gz#g' $a[0].fastp.j$a[0].fastp.json && \\\necho `date` && \\\necho 'DONE' >>$shell_path/Filter_fastp_$a[0].sh.sign\n";
		print LIST "$a[0]\t$abs/$a[0]_1.fq.gz\t$shell_path/Filter_fastp_$a[0].sh\n";
		
	}
	if($a[-1]=~/\.sh$/){
		print DEP "$a[-1]\t$shell_path/Filter_fastp_$a[0].sh\n";
	}else{
		print DEP "$shell_path/Filter_fastp_$a[0].sh\n";
	}
	close OUT;
}
close IN;close LIST;close DEP;
print STDERR "DONE\n";
