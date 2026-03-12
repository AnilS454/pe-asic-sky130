#!/usr/bin/perl
use strict;
use warnings;

# ============================================
# Perl Script: OpenLane Metrics Parser
# Extracts key PPA from metrics.csv
# ============================================

my $file = "/home/anils_0611/vlsi_projects/pe_asic/pnr/config/runs/PE_run2/final/metrics.csv";

open(my $fh, '<', $file) or die "Cannot open $file: $!";

my %metrics;
while(my $line = <$fh>) {
    chomp $line;
    my ($key, $val) = split(',', $line);
    $metrics{$key} = $val;
}
close($fh);

print "\n";
print "=" x 50 . "\n";
print "  PE MODULE — PPA SUMMARY\n";
print "=" x 50 . "\n";
print sprintf("  Die Area          : %.1f um^2\n",  $metrics{"design__die__area"});
print sprintf("  Core Area         : %.1f um^2\n",  $metrics{"design__core__area"});
print sprintf("  Cell Count        : %d\n",          $metrics{"design__instance__count__stdcell"});
print sprintf("  Utilization       : %.1f%%\n",      $metrics{"design__instance__utilization"} * 100);
print sprintf("  Total Power       : %.4f mW\n",     $metrics{"power__total"} * 1000);
print sprintf("  Setup WNS (TT)    : %.3f ns\n",     $metrics{"timing__setup__wns__corner:nom_tt_025C_1v80"});
print sprintf("  Hold WNS (TT)     : %.3f ns\n",     $metrics{"timing__hold__wns__corner:nom_tt_025C_1v80"});
print sprintf("  DRC Errors        : %d\n",          $metrics{"magic__drc_error__count"});
print sprintf("  LVS Errors        : %d\n",          $metrics{"design__lvs_error__count"});
print sprintf("  Antenna Viols     : %d\n",          $metrics{"antenna__violating__nets"});
print "=" x 50 . "\n\n";
