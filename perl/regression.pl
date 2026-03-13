#!/usr/bin/perl
use strict;
use warnings;

# ============================================
# Perl Regression Script — PE Module
# Runs multiple OpenLane configs, compares PPA
# ============================================

my $design_dir = "/home/anils_0611/vlsi_projects/pe_asic/pnr/config";
my $runs_dir   = "$design_dir/runs";

# ============================================
# Step 1 — Define all configurations
# Each element is a hash with run settings
# ============================================
my @configs = (
    { tag => "reg_run1", period => 5.0, density => 0.45, util => 40 },
    { tag => "reg_run2", period => 6.0, density => 0.45, util => 40 },
    { tag => "reg_run3", period => 5.0, density => 0.55, util => 40 },
    { tag => "reg_run4", period => 4.0, density => 0.45, util => 40 },
);

# ============================================
# Step 2 — Store results for each run
# ============================================
my @results;

foreach my $cfg (@configs) {
    my $tag     = $cfg->{tag};
    my $period  = $cfg->{period};
    my $density = $cfg->{density};
    my $util    = $cfg->{util};

    print "\n" . "=" x 55 . "\n";
    print "  Running: $tag | Period: ${period}ns | Density: $density\n";
    print "=" x 55 . "\n";

    # ============================================
    # Step 3 — Generate config.json for this run
    # ============================================
    open(my $cfg_fh, '>', "$design_dir/config.json")
        or die "Cannot write config.json: $!";
    print $cfg_fh qq|{
    "DESIGN_NAME": "PE",
    "VERILOG_FILES": "dir::PE.sv",
    "CLOCK_PORT": "clk",
    "CLOCK_PERIOD": $period,
    "DESIGN_IS_CORE": false,
    "FP_SIZING": "relative",
    "FP_CORE_UTIL": $util,
    "FP_ASPECT_RATIO": 1,
    "PL_TARGET_DENSITY": $density,
    "SYNTH_STRATEGY": "DELAY 0",
    "SYNTH_SIZING": true
}
|;
    close($cfg_fh);

    # ============================================
    # Step 4 — Run OpenLane using system()
    # ============================================
    my $cmd = "cd $design_dir && nix run github:efabless/openlane2 -- --run-tag $tag config.json";
    my $ret = system($cmd);

    if($ret != 0) {
        print "  ERROR: OpenLane failed for $tag — skipping\n";
        next;
    }

    # ============================================
    # Step 5 — Read metrics.csv
    # ============================================
    my $metrics_file = "$runs_dir/$tag/final/metrics.csv";

    unless(-e $metrics_file) {
        print "  ERROR: metrics.csv not found for $tag\n";
        next;
    }

    open(my $mfh, '<', $metrics_file) or die "Cannot open metrics: $!";
    my %metrics;
    while(my $line = <$mfh>) {
        chomp $line;
        my ($key, $val) = split(',', $line, 2);
        $metrics{$key} = $val if defined $val;
    }
    close($mfh);

    # ============================================
    # Step 6 — Store results in array
    # ============================================
    push @results, {
        tag     => $tag,
        period  => $period,
        density => $density,
        area    => $metrics{"design__core__area"}    // "N/A",
        power   => $metrics{"power__total"}           // "N/A",
        wns     => $metrics{"timing__setup__wns__corner:nom_tt_025C_1v80"} // "N/A",
        drc     => $metrics{"magic__drc_error__count"} // "N/A",
        antenna => $metrics{"antenna__violating__nets"} // "N/A",
    };

    print "  Done: area=$results[-1]{area} power=$results[-1]{power} wns=$results[-1]{wns}\n";
}

# ============================================
# Step 7 — Print comparison table
# ============================================
print "\n\n";
print "=" x 75 . "\n";
print "  REGRESSION RESULTS — PE MODULE\n";
print "=" x 75 . "\n";
print sprintf("%-12s %-8s %-8s %-12s %-10s %-8s %-5s %-5s\n",
    "Run", "Period", "Density", "Area(um2)", "Power(mW)", "WNS(ns)", "DRC", "ANT");
print "-" x 75 . "\n";

my ($best_area_run, $best_power_run, $best_wns_run);
my ($best_area, $best_power, $best_wns) = (9e99, 9e99, -9e99);

foreach my $r (@results) {
    my $power_mw = ($r->{power} eq "N/A") ? "N/A" : sprintf("%.3f", $r->{power} * 1000);
    my $wns_fmt  = ($r->{wns}   eq "N/A") ? "N/A" : sprintf("%.3f", $r->{wns});
    my $area_fmt = ($r->{area}  eq "N/A") ? "N/A" : sprintf("%.1f", $r->{area});

    print sprintf("%-12s %-8s %-8s %-12s %-10s %-8s %-5s %-5s\n",
        $r->{tag}, "$r->{period}ns", $r->{density},
        $area_fmt, $power_mw, $wns_fmt,
        $r->{drc}, $r->{antenna});

    # Track best values
    if($r->{area} ne "N/A" && $r->{area} < $best_area) {
        $best_area = $r->{area};
        $best_area_run = $r->{tag};
    }
    if($r->{power} ne "N/A" && $r->{power} < $best_power) {
        $best_power = $r->{power};
        $best_power_run = $r->{tag};
    }
    if($r->{wns} ne "N/A" && $r->{wns} > $best_wns) {
        $best_wns = $r->{wns};
        $best_wns_run = $r->{tag};
    }
}

print "=" x 75 . "\n";
print "  Best Area    : $best_area_run\n" if $best_area_run;
print "  Best Power   : $best_power_run\n" if $best_power_run;
print "  Best Timing  : $best_wns_run\n"  if $best_wns_run;
print "=" x 75 . "\n\n";
