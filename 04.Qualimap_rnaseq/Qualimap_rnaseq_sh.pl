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

`mkdir -p $outdir/shell/Qualimap_rnaseq`;
`mkdir -p $outdir/list`;
open LIST,">$outdir/list/Qualimap_rnaseq.list";
open DEP,">$outdir/list/Qualimap_rnaseq.monitor";
open IN,"$list"; 
while(<IN>){
	next if(/^#/);chomp;
	my @a=split /\t/,$_;
	`mkdir -p $outdir/process/Qualimap_rnaseq/$a[0]`;
	`mkdir -p $outdir/result/$a[0]`;
	open OUT,">$outdir/shell/Qualimap_rnaseq/Qualimap_rnaseq_$a[0].sh";
	my $abs=abs_path("$outdir/process/Qualimap_rnaseq/$a[0]");
	my $shell_path=abs_path("$outdir/shell/Qualimap_rnaseq");
	print OUT "cd $abs\necho -e `date` && \\\n$conf{'Qualimap'} rnaseq -bam $a[1] -gtf $conf{'gtf'} -outdir $abs --java-mem-size=20G -outformat PDF:HTML  && \\\n";
	print OUT "cp -r $abs $outdir/result/$a[0]/Qualimap_rnaseq && \\\n";
	print OUT "echo `date` && \\\necho 'DONE' >>$shell_path/Qualimap_rnaseq_$a[0].sh.sign\n";
	print LIST "$a[0]\t$abs\t$shell_path/Qualimap_rnaseq_$a[0].sh\n";
		
	if($a[-1]=~/\.sh$/){
		print DEP "$a[-1]\t$shell_path/Qualimap_rnaseq_$a[0].sh\n";
	}else{
		print DEP "$shell_path/Qualimap_rnaseq_$a[0].sh\n";
	}
	close OUT;
}
close IN;close LIST;close DEP;
print STDERR "DONE\n";
