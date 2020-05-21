#!/usr/bin/perl
###################################  
#  Author : licong  
#  E-mail : lc@xkybio.com  
###################################
use strict;
use warnings;
use Getopt::Long;
use FindBin '$Bin';
use Cwd 'abs_path';
use File::Basename;
my ($config, $rawList, $outdir,%conf);
GetOptions("conf|c:s" => \$config, "list|l:s" => \$rawList,"outdir|o:s" => \$outdir);
if (!$rawList) {
        die <<USAGE;
==================================================================================
Description: RNAseq Pipeline for Neoantigen
Options: 
            * -list    sample list
              -conf    configure file default [$Bin/RNAseq.conf]
              -outdir  work directory, default [./result]
E.g.:
	perl $0 -list /hdd/public/lc/pipeline/RNAseq/example/rawdata.list -conf /hdd/public/lc/pipeline/RNAseq/RNAseq.conf -outdir result
	perl $0 -list /hdd/public/lc/pipeline/RNAseq/example/rawdata.list
==================================================================================
USAGE
}
$config ||="$Bin/input.conf";
$config =abs_path($config);
$rawList =abs_path($rawList);
$outdir ||="result";
$outdir =abs_path($outdir);`mkdir -p $outdir/result`;
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
open LOG,">./create.log";
my $fqlist=$rawList;
if($conf{'Filter_Module'}){
	system("perl $conf{'Filter_Module'} -c $config -l $fqlist -o $outdir 2>$outdir/err.log");
	print LOG "###Filter\nperl $conf{'Filter_Module'} -c $config -l $rawList -o $outdir\n\n";
	$fqlist="$outdir/list/Filter.list";
	ParseLog('Filter');
}
if($conf{'Deal_Fastq_Module'}){
	system("perl $conf{'Deal_Fastq_Module'} -c $config -l $fqlist -o $outdir 2>$outdir/err.log");
	print LOG "###Deal_Fastq\nperl $conf{'Deal_Fastq_Module'} -c $config -l $fqlist -o $outdir\n\n";
	#"$outdir/list/Deal_Fastq.list";
	ParseLog('Deal_Fastq');
}
if($conf{'STAR_Module'}){
	system("perl $conf{'STAR_Module'} -c $config -l $outdir/list/Deal_Fastq.list -o $outdir 2>$outdir/err.log");
	print LOG "###STAR\nperl $conf{'STAR_Module'} -c $config -l $outdir/list/Deal_Fastq.list -o $outdir\n\n";
	#"$outdir/list/STAR.list";
	ParseLog('STAR');
}
if($conf{'STAR_PE_Module'}){
	system("perl $conf{'STAR_PE_Module'} -c $config -l $outdir/list/Deal_Fastq.list -o $outdir 2>$outdir/err.log");
	print LOG "###STAR_PE\nperl $conf{'STAR_PE_Module'} -c $config -l $outdir/list/Deal_Fastq.list -o $outdir\n\n";
	#"$outdir/list/STAR_PE.list";
	ParseLog('STAR_PE');
}
if($conf{'Qualimap_rnaseq_Module'}){
	system("perl $conf{'Qualimap_rnaseq_Module'} -c $config -l $outdir/list/STAR.list -o $outdir 2>$outdir/err.log");
	print LOG "###Qualimap_rnaseq\nperl $conf{'Qualimap_rnaseq_Module'} -c $config -l $outdir/list/STAR.list -o $outdir\n\n";
	ParseLog('Qualimap_rnaseq');
}
if($conf{'Qualimap_bamqc_Module'}){
	system("perl $conf{'Qualimap_bamqc_Module'} -c $config -l $outdir/list/STAR_PE.list -o $outdir 2>$outdir/err.log");
	print LOG "###Qualimap_bamqc\nperl $conf{'Qualimap_bamqc_Module'} -c $config -l $outdir/list/STAR_PE.list -o $outdir\n\n";
	ParseLog('Qualimap_bamqc');
}
if($conf{'reads_counts_Module'}){
	system("perl $conf{'reads_counts_Module'} -c $config -l $outdir/list/STAR.list -o $outdir 2>$outdir/err.log");
	print LOG "###reads_counts\nperl $conf{'reads_counts_Module'} -c $config -l $outdir/list/STAR.list -o $outdir\n\n";
	ParseLog('reads_counts');
}
if($conf{'UMI_counts_Module'}){
	system("perl $conf{'UMI_counts_Module'} -c $config -l $outdir/list/STAR.list -o $outdir 2>$outdir/err.log");
	print LOG "###UMI_counts\nperl $conf{'UMI_counts_Module'} -c $config -l $outdir/list/STAR.list -o $outdir\n\n";
	ParseLog('UMI_counts');
}
if($conf{'junyixing_Module'}){
	system("perl $conf{'junyixing_Module'} -c $config -l $outdir/list/STAR.list -o $outdir 2>$outdir/err.log");
	print LOG "###junyixing\nperl $conf{'junyixing_Module'} -c $config -l $outdir/list/STAR.list -o $outdir\n\n";
	ParseLog('junyixing');
}
if($conf{'table3_Module'}){
	system("perl $conf{'table3_Module'} -c $config -l $outdir/list/reads_counts.list -o $outdir 2>$outdir/err.log");
	print LOG "###table3\nperl $conf{'table3_Module'} -c $config -l $outdir/list/STAR.list -o $outdir\n\n";
	ParseLog('table3');
}
if($conf{'table4_Module'}){
	system("perl $conf{'table4_Module'} -c $config -l $outdir/list/STAR_PE.list -o $outdir 2>$outdir/err.log");
	print LOG "###table4\nperl $conf{'table4_Module'} -c $config -l $outdir/list/STAR_PE.list -o $outdir\n\n";
	ParseLog('table4');
}
if($conf{'merge_Module'}){
	system("perl $conf{'merge_Module'} -c $config -l $outdir/list/junyixing.list -o $outdir 2>$outdir/err.log");
	print LOG "###merge\nperl $conf{'merge_Module'} -c $config -l $outdir/list/merge.list -o $outdir\n\n";
	ParseLog('merge');
}
if($conf{'map_stat_Module'}){
	system("perl $conf{'map_stat_Module'} -c $config -l $outdir/list/Qualimap_rnaseq.list -o $outdir 2>$outdir/err.log");
	print LOG "###map_stat\nperl $conf{'map_stat_Module'} -c $config -l $outdir/list/Qualimap_rnaseq.list -o $outdir\n\n";
	ParseLog('map_stat');
}

`cat $outdir/list/*.monitor >$outdir/All.monitor.txt`;
my $if_mail=($conf{'mail'})?"-mail_to $conf{'mail'}":"";
my $run="$conf{'monitor'} submit $outdir/All.monitor.txt $if_mail";
Write("$outdir/start_run.sh",$run);
my $scp="scp 20191223_result.tar.gz wuyushuai\@1t.tongyuangene.com:/ifs1/User/wuyushuai/for_Wangtong_file_transfer/waitting_unzip\n";
Write("$outdir/scp.sh",$scp);
my $rm="rm -f process/*/*/*/*sam\nrm -f process/*/*/*sam\n";
Write("$outdir/rm.sh",$rm);

sub Write {
        my ($file, $context) = @_;
        open FILE,">$file" or die $!;
        print FILE "$context\n";
        close FILE;
}

sub ParseLog {
        my $step = shift;
        open ELOG,"$outdir/err.log" or die $!;
        my $message = "";
        while (<ELOG>) {
                next if (/^\s*$/);chomp;
                $message .= "$_\n";
        }
        close ELOG;
        system("rm $outdir/err.log");
        my $len = length($step);
        if ($message eq "DONE\n") {
                my $rep = 15 - $len;
                print "Generating shell scripts for $step ......" . "."x$rep . " [DONE]\n";
        }elsif ($message =~ s/DONE\n$//) {
                my $rep = 15 - $len;
                print "Generating shell scripts for $step ......" . "."x$rep . " [WARN]\n";
                print "WarningMessage: $message";
        }else {
                my $rep = 15 - $len - 1;
                print "Generating shell scripts for $step ......" . "."x$rep . " [ERROR]\n";
                print "ErrorMessage: $message";
                exit;
        }
}
