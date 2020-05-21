#!/usr/bin/perl -w
#

$Rscript=$ARGV[2];

open IN,"$ARGV[0]";<IN>;
$ARGV[1] ||= "test";
open OUT,">$ARGV[1].gc.data";
print OUT "gene\tGC_Content1\tlog10_UMI_Count\n";
open OUT2,">$ARGV[1].length.data";
print OUT2 "gene\tGene_Length1\tlog10_UMI_Count\n";
while(<IN>){
	chomp;
	my @a=split /\t/,$_;
	$a[2]=log($a[2])/log(10);
	my ($l,$c);
	if($a[3] < 1000){
		$l="<1";
	}elsif($a[3]<2000){
		$l="[1-2)";
	}elsif($a[3]<3000){
		$l="[2-3)";
	}elsif($a[3]<4000){
		$l="[3-4)";
	}elsif($a[3]<5001){
		$l="[4-5]";
	}else{
		$l=">5";
	}	
	print OUT2 "$a[0]\t$l\t$a[2]\n";
	if($a[4] < 0.3){
		$c="<0.3";
	}elsif($a[4]<0.4){
		$c="[0.3-0.4)";
	}elsif($a[4]<0.5){
		$c="[0.4-0.5)";
	}elsif($a[4]<0.6){
		$c="[0.5-0.6)";
	}elsif($a[4]<0.7){
		$c="[0.6-0.7]";
	}else{
		$c=">0.7";
	}	
	print OUT "$a[0]\t$c\t$a[2]\n";
}
open R,">$ARGV[1].R";
print R "library(ggplot2)\npdf(file=\"./$ARGV[1]_GC.pdf\")\na<-read.table(\"./$ARGV[1].gc.data\",head=T,check.names=F)\na\$GC_Content <- factor(a\$GC_Content1, levels=factor(c('<0.3','[0.3-0.4)','[0.4-0.5)','[0.5-0.6)','[0.6-0.7]','>0.7')))\nggplot(a,aes(x=GC_Content,y=log10_UMI_Count))+geom_boxplot() + labs(title='$ARGV[1]') + theme(axis.title = element_text(size = 15))+ theme(axis.text = element_text(size = 15))\ndev.off()\n";

print R "library(ggplot2)\npdf(file=\"./$ARGV[1]_Length.pdf\")\na<-read.table(\"./$ARGV[1].length.data\",head=T,check.names=F)\na\$Gene_Length <- factor(a\$Gene_Length1, levels=factor(c('<1','[1-2)','[2-3)','[3-4)','[4-5]','>5')))\nggplot(a,aes(x=Gene_Length,y=log10_UMI_Count))+geom_boxplot() + labs(x = \"Gene_Length(kb)\") + labs(title='$ARGV[1]') + theme(axis.title = element_text(size = 15))+ theme(axis.text = element_text(size = 15))\ndev.off()\n";
close R;
#`Rscript $ARGV[1].R && rm $ARGV[1].gc.data $ARGV[1].length.data`
`$Rscript $ARGV[1].R `
