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

`mkdir -p $outdir/shell/map_stat`;
`mkdir -p $outdir/process/map_stat`;
`mkdir -p $outdir/list`;
open LIST,">$outdir/list/map_stat.list";
open DEP,">$outdir/list/map_stat.monitor";
open IN,"$list"; 
while(<IN>){
	next if(/^#/);chomp;
	my @a=split /\t/,$_;
	my $shell_path=abs_path("$outdir/shell/map_stat");
	print DEP "$a[-1]\t$shell_path/map_stat.sh\n";
}
open OUT,">$outdir/shell/map_stat/map_stat.sh\n";
print OUT "cd $outdir/process/map_stat \necho -e `date` && \\\n";
print OUT "perl $Bin/x.pl $outdir/process/Qualimap_rnaseq $conf{'Rscript'} && \\\n";
print OUT "perl $Bin/y.pl $outdir/process/STAR $conf{'Rscript'} && \\\n";
print OUT "cp -r $outdir/process/map_stat $outdir/result && \\\n";
print OUT "echo `date` && \\\necho 'DONE' >>$outdir/shell/map_stat/map_stat.sh.sign\n";
print LIST "SUMMARY\t$outdir/process/map_stat\t$outdir/shell/map_stat/map_stat.sh\n";
close OUT;
close IN;close LIST;close DEP;
print STDERR "DONE\n";
