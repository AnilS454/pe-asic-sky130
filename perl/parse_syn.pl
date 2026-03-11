#!/usr/bin/perl
use strict;
use warnings;

# ============================================
# Perl Script: Synthesis Report Parser
# Parses Yosys synthesis log and extracts
# key statistics into a clean summary table
# ============================================

#------- Config -----
my $logfile='/home/anils_0611/vlsi_projects/pe_asic/syn/output/syn_log.txt';

#------- Open the log file -------
open(my $fh, '<', $logfile) or die "Cannot open $logfile: $!";

#--- Variables to store results ---
my %cells; #for individual cells
my $total_cells = 0;
my $total_wires = 0;
my $total_wirebits = 0;
my $in_stats =0;

#---- Pass line by line ----
while(my $line = <$fh>){
chomp $line;
if($line =~ /Printing statistics/){
$in_stats = 1;
}

next unless $in_stats;

#--- Extracting wires count ---
if($line =~ /^\s+(\d+)\s+wires\s*$/){
$total_wires = $1;
}

#--- Extracting wire bits count ---
if($line =~ /^\s+(\d+)\s+wire\s+bits\s*$/){
$total_wirebits = $1;
}

#--- Extracting cells coutn ---

if($line =~ /^\s+(\d+)\s+cells\s*$/){
$total_cells = $1;
}

#--- Extracting individual cells count ---
if($line =~ /^\s+(\d+)\s+(sky130_\w+)\s*$/){
$cells{$2}=$1;
}
}
close($fh);


# --- Print Summary ---
print "\n";
print "=" x 50 . "\n";
print "  SYNTHESIS REPORT SUMMARY — PE Module\n";
print "=" x 50 . "\n\n";

printf "  %-20s %s\n", "Wires:",      $total_wires;
printf "  %-20s %s\n", "Wire Bits:",  $total_wirebits;
printf "  %-20s %s\n", "Total Cells:", $total_cells;

print "\n  --- Cell Breakdown ---\n\n";
printf "  %-25s %s\n", "Cell Type", "Count";
printf "  %-25s %s\n", "-" x 24,    "-" x 5;

# Sort by count descending
foreach my $cell (sort { $cells{$b} <=> $cells{$a} } keys %cells) {
    printf "  %-25s %d\n", $cell, $cells{$cell};
}

print "\n" . "=" x 50 . "\n";
print "  Log file: $logfile\n";
print "=" x 50 . "\n\n";
