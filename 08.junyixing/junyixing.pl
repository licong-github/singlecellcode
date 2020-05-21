use strict;
use warnings;
use autodie;

if(@ARGV<2){
	  print "perl $0 <sam: wellcode umi> <output> gtf\n";
	  exit;
}
my %ha;
open GTF,"$ARGV[3]";
while(<GTF>){
	next if(/^#/);
	my @a=split /\t/,$_;
	if($a[2] eq "exon"){
		for($a[3]..$a[4]){
			$ha{$a[0]}{$_}="";
		}
	}
	
}
close GTF;
my %sam;
my %mut_map;

my %total;

open FO,">$ARGV[1]\n";
my $time=localtime();
print  "$time\n";

read_sam($ARGV[0],"human");
open LIST,"$ARGV[2]";
my @sort;
while(<LIST>){
	chomp;
	my @a=split /\s+/,$_;
	push @sort,$a[0];
}
close LIST;
print FO "wellcode\ttotal_umi_kinds\tmapped_umi_kinds\ttotal_reads\tmapped_reads\texon_mapped_reads\tno_exon_mapped_reads\tunique-maped_reads\tmuti_mapped_reads\tun_maped_reads\n";
#foreach my $wellcode(keys %sam){
foreach my $wellcode(@sort){
	  
	  my $total_reads=keys %{$sam{$wellcode}{read}{total}};
	  my $total_umi=keys %{$sam{$wellcode}{umi}{total}};
	  my $reads=keys %{$sam{$wellcode}{read}{mapped}};
	  my $exon_reads=keys %{$sam{$wellcode}{read}{mapped_exon}};
	  my $umi=keys %{$sam{$wellcode}{umi}{mapped}};
	  my $mut_mapped_reads=keys %{$sam{$wellcode}{read}{muti_mapped}};
          my $uniq_mapped_reads=$reads-$mut_mapped_reads;
	  my $no_exon_mapped_reads=$reads-$exon_reads;
	  my $un_mapped_reads=$total_reads-$mut_mapped_reads-$uniq_mapped_reads;
	  print FO "$wellcode\t$total_umi\t$umi\t$total_reads\t$reads\t$exon_reads\t$no_exon_mapped_reads\t$uniq_mapped_reads\t$mut_mapped_reads\t$un_mapped_reads\n";
}


sub read_sam {
	  my ($file,$tag)=@_;
	  

   open FF,$file;
    while(<FF>){
    	  next if /^@/;
    	  chomp;
    	  my @terms=split /\t/,$_;
    	  my $flag=0;
    
    	  if($terms[1] & 0x40){
    	  	 $flag=1;
    	  	 
    	  }
    	  
    	  $total{"total_reads_$tag"}{"$terms[0].$flag"}++ ;
    
    	  my @id=split /:/,$terms[0];
    	  my $read="$terms[0].$flag";
    	  
    	  $sam{$id[-2]}{read}{total}{$read}++;
    	  $sam{$id[-2]}{umi}{total}{$id[-1]}++;
    	 
    	  if($terms[2] ne "*" and $terms[5] ne "*"){
    	  	  if($sam{$id[-2]}{read}{mapped}{$read}){
			$sam{$id[-2]}{read}{muti_mapped}{$read}++;
		  }
    	  	  $sam{$id[-2]}{read}{mapped}{$read}++;
    	  	  $sam{$id[-2]}{umi}{mapped}{$id[-1]}++;
    	  	  if(exists $ha{$terms[2]}{$terms[3]}){
			$sam{$id[-2]}{read}{mapped_exon}{$read}++;
		  }
    	  }
    	
    }
    
}    
#exit;
close FF;
$time=localtime();
print  "$time\n";
#my %uniq;



