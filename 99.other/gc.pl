#!/usr/bin/perl -w
#
my (%chr);
my $seq="";
my $id="";
#open IN,"/hdd/public/lc/database/human/hg19/Ensembl_GRCh37.75/ChrALL.fa";
open IN,"/hdd/database/10X/refdata-cellranger-hg19-1.2.0/fasta/genome.fa";
open GTF,"/hdd/database/10X/refdata-cellranger-hg19-1.2.0/genes/genes.gtf";
#open GTF,"/hdd/database/Homo_sapiens/Homo_sapiens.GRCh37.75.chr.gtf";
open G,">gene_GC.txt";
print G "Gene\tLenth\tLocation1\tLocation2\tGC\n";
open T,">transcript_GC.txt";
while(<IN>){
	chomp;
#	if(/^>(chr\S+)/){
	if(/^>(\S+)/){
		$chr{$id}=$seq;
		$id=$1;
		$seq ="";
	}else{
		$seq.=$_;
	}
}
close IN;
my %uniq;
while(<GTF>){
	my @a=split /\t/,$_;
	next unless($a[2] eq 'gene' || $a[2] eq 'transcript');
	if($a[-1]=~/^gene_id\s+"(\w+)".*gene_name\s+"(\S+)";/){
		$g=$1;
		$n=$2;
	}
	if($a[-1]=~/^gene_id\s+"(\w+)".*transcript_id\s+"(\w+)"/){
		$g=$1;
		$t=$2;
	}
	my $l=$a[4]-$a[3];
#	my $nseq=substr($chr{"chr$a[0]"},$a[3],$l);
	my $nseq=substr($chr{"$a[0]"},$a[3],$l);
	my $count_G=$nseq=~tr/G//;
	my $count_C=$nseq=~tr/C//;
	my $GC=sprintf "%.2f",(($count_G+$count_C)/$l);
	if($a[2] eq 'gene'){
		next if($uniq{$n});
#		print G "$g\t$l\tchr$a[0]:$a[3]\tchr$a[0]:$a[4]\t$GC\n";
		print G "$n\t$l\tchr$a[0]:$a[3]\tchr$a[0]:$a[4]\t$GC\n";
		$uniq{$n}=1;
	}elsif($a[2] eq 'transcript'){
		print T "$t\t$l\t$GC\n";
	}
}
close GTF;
close G;
close T;
