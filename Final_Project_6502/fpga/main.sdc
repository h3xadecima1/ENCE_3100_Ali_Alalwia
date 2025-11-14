# ================================================================
# main.sdc — Timing Constraints for DE10-Lite 6502 Project
# ================================================================

# On-board 50 MHz clock (from oscillator connected to PIN_P11)
create_clock -name clk -period 20.000 [get_ports {clk}]

# Add small clock uncertainty margins
derive_clock_uncertainty

# Derive PLL clocks if any exist (not used here but safe)
derive_pll_clocks

# Input delay for push buttons, switches, etc.
set_input_delay  5.0 -clock clk [all_inputs]

# Output delay for LEDs, displays, etc.
set_output_delay 5.0 -clock clk [all_outputs]
