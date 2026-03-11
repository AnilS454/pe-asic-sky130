# ============================================
# OpenSTA Script — PE Module
# ============================================

# --- Load Liberty file (SKY130 timing library) ---
read_liberty /home/anils_0611/.volare/volare/sky130/versions/0fe599b2afb6708d281543108caf8310912f54af/sky130A/libs.ref/sky130_fd_sc_hd/lib/sky130_fd_sc_hd__tt_025C_1v80.lib

# --- Load Netlist ---
read_verilog /home/anils_0611/vlsi_projects/pe_asic/syn/output/PE_netlist_clean.v

# --- Link design ---
link_design PE

# --- Load Constraints ---
read_sdc /home/anils_0611/vlsi_projects/pe_asic/sta/constraints/pe.sdc

# --- Run Timing Reports ---
puts "\n=========================================="
puts " SETUP TIMING REPORT"
puts "==========================================\n"
report_checks -path_delay max -fields {slew cap input nets fanout} -format full_clock_expanded

puts "\n=========================================="
puts " HOLD TIMING REPORT"  
puts "==========================================\n"
report_checks -path_delay min -fields {slew cap input nets fanout} -format full_clock_expanded

puts "\n=========================================="
puts " TIMING SUMMARY"
puts "==========================================\n"
report_check_types -max_slew -max_cap -max_fanout -violators

puts "\n=========================================="
puts " WORST NEGATIVE SLACK"
puts "==========================================\n"
report_wns
report_tns

exit
