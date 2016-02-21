#!/usr/bin/perl
use strict;
use warnings;

use vars qw($ctr $fh $flag  $pq_modified $pq_original $solution_file);
use vars qw(@output @solution @temp_out);

$pq_original = shift;   #the original pocket query
$solution_file = shift; #the file with the new coordinates,...
$pq_modified = $pq_original; #output file
$pq_modified =~ s/\.gpx$/\_solved\.gpx/;
$flag = 0;
$ctr = 0;

#Read solution file
open($fh, "<$solution_file") or die "Can't open file: $!";
while(<$fh>){
	my $line = $_;
	my @fields = split " ", $line;
	for (my $i = 0; $i<3; $i++){
		$solution[$ctr][$i] = $fields[$i];
	}
	$ctr++;
}
close $fh;

#Umrechnung der Loesungen
for(0..$#solution){
	$solution[$_][1] =~ s/N//;
	$solution[$_][1] =~ s/S/-/;
	$solution[$_][1] =~ /(\d*\.\d*)/;
	my $modified = $1*1000000/60;
	$modified =~ s/\..*//;
	$solution[$_][1] =~ s/(\d*\.\d*)/$modified/;
	$solution[$_][1] =~ s/°/./;
	
	$solution[$_][2] =~ s/E//;
	$solution[$_][2] =~ s/W/-/;
	$solution[$_][2] =~ /(\d*\.\d*)/;
	$modified = $1*1000000/60;
	$modified =~ s/\..*//;
	$solution[$_][2] =~ s/(\d*\.\d*)/$modified/;
	$solution[$_][2] =~ s/°/./;
}

open($fh, "<$pq_original") or die "Can't open file: $!";
while(<$fh>){
	my $line = $_;
	$flag = 1 if($line =~ /<wpt/);
	if ($flag == 0){
		push(@output,$line);
	}
	else{
		push(@temp_out,$line);
	}
	if($line =~ /^\s*<name>/){
		my $temp = $line;
		$temp =~ s/^\s*<name>//;
		$temp =~ s/\s*<\/name>\s*$//;
		for(0..$#solution){
			#print "Solution: $solution[$_][0]\ntemp: $temp\n";
			if ($solution[$_][0] eq $temp){
				$temp_out[0] =~ s/lat="\d*\.\d*"/lat="$solution[$_][1]"/;
				$temp_out[0] =~ s/lon="\d*\.\d*"/lon="$solution[$_][2]"/;
				last;
			}
		}
		push(@output,@temp_out);
		@temp_out = ();
		$flag = 0;
	}
}
close $fh;

open($fh, ">$pq_modified") or die "Can't create file: $!";
print $fh @output;
close $fh;