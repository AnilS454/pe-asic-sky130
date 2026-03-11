# ============================================
# SDC Constraints — PE Module
# Target: 500MHz (2ns period)
# ============================================

# --- Define Clock ---
create_clock -name clk \
             -period 5.000 \
             -waveform {0 1} \
             [get_ports clk]

# --- Clock Uncertainty (jitter) ---
set_clock_uncertainty 0.1 [get_clocks clk]

# --- Input Delays ---
set_input_delay -clock clk -max 0.5 [get_ports {reset clear_acc v_a_in v_b_in a_in b_in}]

# --- Output Delays ---
set_output_delay -clock clk -max 0.5 [get_ports {v_a_out v_b_out a_out b_out psum}]

# --- Drive Strength ---
set_driving_cell -lib_cell sky130_fd_sc_hd__buf_1 [get_ports {reset clear_acc v_a_in v_b_in a_in b_in}]

# --- Load ---
set_load 0.01 [get_ports {v_a_out v_b_out a_out b_out psum}]
