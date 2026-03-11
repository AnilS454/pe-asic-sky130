#!/usr/bin/perl
use strict;
use warnings;

# ============================================
# Perl Script: Netlist Cleaner
# Removes duplicate reg declarations
# that Yosys generates after input/output
# ============================================
my $input='/home/anils_0611/vlsi_projects/pe_asic/syn/output/PE_netlist.v';
my $output = '/home/anils_0611/vlsi_projects/pe_asic/syn/output/PE_netlist_clean.v';

open(my $in, '<', $input) or die "Cannot open $input file: $!\n";
open(my $out, '>', $output) or die "Cannot open $output file: $! \n";

my %declared;
while(my $line=<$in>){
if($line =~ /^\s+(input|output)\s+.*?(\w+)\s*;/){
$declared{$2}=1;
print $out $line;
next;
}

if($line =~ /^\s+(reg)\s+.*?(\w+)\s*;/){
if(exists $declared{$2}){
next; #skip
}
}
print $out $line;
}
close($in);
close($out);






