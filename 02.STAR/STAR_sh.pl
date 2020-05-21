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

`mkdir -p $outdir/shell/STAR`;
`mkdir -p $outdir/list`;
open LIST,">$outdir/list/STAR.list";
open DEP,">$outdir/list/STAR.monitor";
open IN,"$list"; 
while(<IN>){
	next if(/^#/);chomp;
	my @a=split /\t/,$_;
	`mkdir -p $outdir/process/STAR/$a[0]`;
	open OUT,">$outdir/shell/STAR/STAR_$a[0].sh";
	my $abs=abs_path("$outdir/process/STAR/$a[0]");
	my $shell_path=abs_path("$outdir/shell/STAR");
	print OUT "cd $abs\necho -e `date` && \\\n$conf{'STAR'} $conf{'STAR_opts'} --readFilesIn $a[1] --outFileNamePrefix $a[0]. --genomeDir $conf{'STAR_genomeDir'}  && \\\necho `date` && \\\necho 'DONE' >>$shell_path/STAR_$a[0].sh.sign\n";
	print LIST "$a[0]\t$abs/$a[0].Aligned.out.sam\t$shell_path/STAR_$a[0].sh\n";
		
	if($a[-1]=~/\.sh$/){
		print DEP "$a[-1]\t$shell_path/STAR_$a[0].sh\n";
	}else{
		print DEP "$shell_path/STAR_$a[0].sh\n";
	}
	close OUT;
}
close IN;close LIST;close DEP;
print STDERR "DONE\n";
