#!/usr/bin/perl
use strict;
use warnings;

# Read in sam files
open(my $fi,"<",$ARGV[0]) or die "Could not open input";

# Specify output files
open(my $fo,">",$ARGV[1]) or die "Could not open output";

my $trim_pos=0;
my $trim_neg=0;
# Loop through mapped reads
while(my $line=<$fi>)
{	chomp($line);
	my @a=split(/\t/,$line);
	if(substr($line,0,1) eq "@" | $a[1] eq 4)
	{	next;
	}

	$a[5]=~s/M//;
	my $read_length=$a[5];
	my $num_mismatch=chop $a[$#a];
	my $read_name=$a[0];
	my $strand=$a[1];
	my $read=$a[9];
	my $score=$a[10];
	my $mismatch=$a[12];

	if($num_mismatch>0)
	{	my @mm_split=split(/[A-Z]/,$mismatch);
		if($strand==0 && substr($mismatch,5,1)==0)	# Check if the first character on the positive strand is a mismatch 
		{	$read_length--;
			$read=substr($read,1,$read_length);		# Delete the first nucleotide of the read
			$score=substr($score,1,$read_length);
			$trim_pos++;
		}
		elsif($strand==16 && $mm_split[$#mm_split]==0)	# Check if the last character on the negative strand read is a mismatch 
		{	$read_length--;
			$read=substr($read,0,$read_length);
			$score=substr($score,0,$read_length);
			$trim_neg++;
		}
	}		

	if($strand==16) # Check if the read maps to the negative strand
	{	$read=reverse($read);	# Reverse the negative strand
		$read=~tr/ATGC/TACG/;	# Complement of the negative strand
		$score=reverse($score);
	} 
	
	print $fo "@","$read_name\n","$read\n+\n$score\n";
}
print "+ strand trimmed = $trim_pos\n";
print "- strand trimmed = $trim_neg\n";
close($fi);
close($fo);
