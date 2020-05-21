use warnings;
use strict;
use Getopt::Long; 
use autodie;
use File::Spec;
use File::Basename;
use POSIX qw(strftime);
use Data::Dumper;
use List::Util qw(sum max min);


if(@ARGV<6){
	print "perl $0 <barcode> <fq1> <fq2> <outputprefix> <umi length > <welllcode length>\n";
	exit;
}
my $time=localtime();
print STDERR "$time\n";
my %barcode;
open FB,$ARGV[0];
while(<FB>){
	 chomp;
	 my $t=reverse $_;
   $t=~tr/ATGC/TACG/;
   $barcode{$_}=$t;
	 
}
close FB;

my $line=0;
open FQ1,"less $ARGV[1] | ";
open FQ2,"less $ARGV[2] | ";
open FOSEQ1,">$ARGV[3]_1.fq";
open FOSEQ2,">$ARGV[3]_2.fq";
open FOSEQUN,">$ARGV[3].un.fq";
open FST,">$ARGV[3].stats.xls";
my %position;
my %stats;
my $total_reads=0;
my $total=0;
my $wellcode192=0;
my %umi;
my($pos,$rev,$N);	###licong 
while(<FQ1>){
	 
	 my $id1=$_;
	 my $seq1= <FQ1>;
	 my $cp1= <FQ1>;
	 my $qual1= <FQ1>;
	 
	 my $id2= <FQ2>;
	 my $seq2= <FQ2>;
	 my $cp2= <FQ2>;
	 my $qual2= <FQ2>;
	 
	 chomp $id1;
	 chomp $id2;
	 chomp $seq1;
	 chomp $seq2;
	 chomp $qual1;
	 chomp $qual2;
	 
	 
	 $line++;
	 if($line %1000000==0){
	 	     my $time=localtime();
         print STDERR "$line $time\n";
	 }
	 
	 $stats{total_reads}+=2;
	 $stats{total_bases}+=(length $seq1)+(length $seq2);
	 
	 
	 my($wellcode1,$umi1,$illumnaseq1,$transeq1)=();#Find_wellcode_umi($seq1); ###licong
	 my($wellcode2,$umi2,$illumnaseq2,$transeq2)=Find_wellcode_umi($seq2);  ###licong
	 
	 if($wellcode1 and $wellcode2){
	 	   if( ($wellcode1 eq $wellcode2) and ($umi1 eq $umi2) ){
	 	   	   if(length $transeq1>15 and length $transeq2>15){
	 	   	        Out_seq($wellcode1,$umi1,$seq1,$transeq1,$qual1,$id1,1);
	 	   	        Out_seq($wellcode2,$umi2,$seq2,$transeq2,$qual2,$id2,2);
	 	   	        $stats{two_wellcode_eq_reads}+=2;
	              $stats{two_wellcode_eq_bases}+=(length $seq1)+(length $seq2);
	         }
	 	   }else{
	 	   	   print FOSEQUN "$wellcode1,$umi1,$illumnaseq1,$transeq1,$wellcode2,$umi2,$illumnaseq2,$transeq2\n";
	 	   	   $stats{two_wellcode_ue_reads}+=2;
	         $stats{two_wellcode_ue_bases}+=(length $seq1)+(length $seq2);
	 	   }
	 }
	 elsif($wellcode1 ){
	 	   if(length $transeq1>15){
	          Out_seq($wellcode1,$umi1,$seq1,$transeq1,$qual1,$id1,1);
	          Out_seq($wellcode1,$umi1,$seq2,$seq2,$qual2,$id2,2);
	          $stats{read1_wellcode_reads}+=2;
	          $stats{read1_wellcode_bases}+=(length $seq1)+(length $seq2);
	     }
	 }
	 elsif($wellcode2 ){
	 	   if(length $transeq2>15){
	         Out_seq($wellcode2,$umi2,$seq2,$transeq2,$qual2,$id2,2);
	         Out_seq($wellcode2,$umi2,$seq1,$seq1,$qual1,$id1,1);
	         $stats{read2_wellcode_reads}+=2;
	         $stats{read2_wellcode_bases}+=(length $seq1)+(length $seq2);
	     }
	 }else{
	 	   $stats{no_wellcode_reads}+=2;
	     $stats{no_wellcode_bases}+=(length $seq1)+(length $seq2);
	 }
}

foreach my $s(sort keys %stats){
	  print FST "$s\t$stats{$s}\n";
}

my $wellcode_percent=($stats{total_reads}-$stats{no_wellcode_reads})/$stats{total_reads};
print FST "wellcode_percent\t$wellcode_percent\n\n";
my $wellcode_percent2=$N/$stats{total_reads}*2;
print FST "wellcode_percent\t$wellcode_percent2\n\n";

foreach my $f(sort keys %position){
	  #print FST "$f\n";
	  foreach my $s( sort { $a <=>  $b } keys %{$position{$f} }){
	  	  print FST "$f\t$s\t$position{$f}{$s}\n";
	  }
}
print FST "POS:	$pos\nREV:	$rev\n";
print "$total_reads\t$total\t$wellcode192\n";
$time=localtime();
print STDERR "$time\n";

sub Find_wellcode_umi {
    my ($seq)=@_;
    $total_reads++;
   my $wellcode;
   my $umi; 
   my $transeq;
   my $illuminaseq;
	 
	  my $flag=0;
	  my $ff=0;
	  if($seq=~m/^(\w*[TGC])A{10,}(\w{$ARGV[4]})(\w{$ARGV[5]})(\w*)/){ 
	  	      #print "1 $1 $2 $3 $4 $seq\n";   
                 $ff++;
                 my $t3=$3;                 
                 $t3=reverse $t3;
                 $t3=~tr/ATGC/TACG/;
                 my $t1=$1;
                my $t2=$2;
                $t2=reverse $t2;
                $t2=~tr/ATGC/TACG/;
                 my $t4=$4;
                  if($barcode{$t3}){
                 	   $wellcode=$t3;
                 	   $transeq=$t1;
                 	   $illuminaseq=$4;
                 	   $umi=$t2;
                 	   $flag++;
                 	   #last;
                 	   $rev++; ###licong
                  }
                  
                 
   	 }
    if($flag==0){
#         if($seq=~m/^(\w*?)(\w{$ARGV[5]})(\w{$ARGV[4]})T{9,}([GCA]\w*)/ && $barcode{$2}){
         if($seq=~m/^(\w*?)(\w{$ARGV[5]})(\w{$ARGV[4]})T{9,}([GCA]\w*)/){
#         if($seq=~m/^()(\w{$ARGV[5]})(\w{$ARGV[4]})T{9,}([GCA]\w*)/){
		$N++;
                  #print "2 $1 $2 $3 $4 $seq\n";   
                 $ff++;
                 my $t1=$1;
                 my $t3=$3;
                 my $t4=$4;
                 my $t2=$2; 
                 
                 if($barcode{$t2}){
                 	   $wellcode=$t2;
                 	   $transeq=$t4;
                 	   $illuminaseq=$t1;
                 	   $umi=$t3;
                 	   $flag++;  
                 	   #last;
                 	   $pos++; ###licong
                 }else{
			foreach my $b(keys %barcode){
				my $dis=Compare($t2,$b);
				next if($dis > 1);
				$wellcode=$b; #矫正wellcode
				$transeq=$t4;
				$illuminaseq=$t1;
				$umi=$t3;
				$flag++;
				$pos++;
				last;
			}
#			print "$t2\n";
		}
         }
=h
elsif($seq=~m/^(\w*?)(\w{$ARGV[5]})(\w{9}T)T{8,}([GCA]\w*)/ && $barcode{$2}){
		$N++;
                  #print "2 $1 $2 $3 $4 $seq\n";   
                 $ff++;
                 my $t1=$1;
                 my $t3=$3;
                 my $t4=$4;
                 my $t2=$2; 
                 
                 if($barcode{$t2}){
                 	   $wellcode=$t2;
                 	   $transeq=$t4;
                 	   $illuminaseq=$t1;
                 	   $umi=$t3;
                 	   $flag++;  
                 	   #last;
                 	   $pos++; ###licong
                 }
         }elsif($seq=~m/^(\w*?)(\w{$ARGV[5]})(\w{8}TT)T{7,}([GCA]\w*)/){
                  #print "2 $1 $2 $3 $4 $seq\n";   
                 $ff++;
                 my $t1=$1;
                 my $t3=$3;
                 my $t4=$4;
                 my $t2=$2; 
                 
                 if($barcode{$t2}){
		$N++;
                 	   $wellcode=$t2;
                 	   $transeq=$t4;
                 	   $illuminaseq=$t1;
                 	   $umi=$t3;
                 	   $flag++;  
                 	   #last;
                 	   $pos++; ###licong
                 }
         }      
=cut 
    }
    if($ff>0){
    	  $total++;
    }
    if($flag>0){
    	 $wellcode192++;
    }
   
   if ($umi){
   	    $umi{umi}{$umi}{$wellcode}++ ;
        $umi{wellcode}{$wellcode}{$umi}++;
       
   }
   return($wellcode,$umi,$illuminaseq,$transeq);
    
}

sub Out_seq {
	 my($wellcode1,$umi1,$seq1,$transeq1,$qual1,$id1,$file)=@_;
	 #print " my($wellcode1,$umi1,$seq1,$transeq1,$qual1,$id1,$file)=@_;\n";
	 my $len1=index($seq1,$transeq1);
	 
	 
	 #$len1=length $illumnaseq1 if $illumnaseq1;
	 my $qualf1=substr($qual1,$len1,length $transeq1);
	 my @id=split /\s+/,$id1;
	 my $newid="$id[0]:$wellcode1:$umi1 $id[1]";
	 if($file==1){
	    print FOSEQ1 "$newid\n";
	    print FOSEQ1 "$transeq1\n+\n";
	    print FOSEQ1 "$qualf1\n";
	    
	    my $start=(length $seq1)-( length $transeq1);
	    
	    $position{$file}{$start}++ if $start >0;
	 }else{
	 	  print FOSEQ2 "$newid\n";
	    print FOSEQ2 "$transeq1\n+\n";
	    print FOSEQ2 "$qualf1\n";
	    
	    
	    
	    my $start=$len1-15 ;
	    
	    $position{$file}{$start}++ if $start >0;
	    
	 }
	     
	 $stats{filter_reads}++;
	 $stats{filter_bases}+=length $transeq1; 	   	  
	 
	 $umi{len}{$len1}++;   	    
}
print "$N\n";

sub Compare {
          my ($seq1,$seq2)=@_;
          #if($seq1 eq $seq2)
          my @seq1=split '',$seq1;
          my @seq2=split '',$seq2;
          my $diff=0;
          foreach my $i(0..$#seq1){
             if($seq1[$i] ne $seq2[$i]){
                   $diff++;
		   last if($diff>2);
             }
             #$i++;
          }
          return($diff);
}
