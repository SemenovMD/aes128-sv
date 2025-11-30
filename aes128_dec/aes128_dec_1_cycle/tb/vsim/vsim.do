# Enable transcript logging
transcript on

# Create the work library
vlib work

# Compile the design and testbench
vlog -sv    aes128_dec/aes128_dec_1_cycle/rtl/aes128_dec_core.sv
vlog -sv    aes128_dec/aes128_dec_1_cycle/rtl/axis_rr_mux_rx.sv
vlog -sv    aes128_dec/aes128_dec_1_cycle/rtl/axis_rr_mux_tx.sv
vlog -sv    aes128_dec/aes128_dec_1_cycle/rtl/aes128_dec_core_cluster.sv
vlog -sv    aes128_dec/aes128_dec_1_cycle/tb/tb_aes128_dec.sv

# Simulate the testbench
vsim -t 1ns -L altera_mf_ver -voptargs="+acc" tb_aes128_dec

# Add signals to the waveform window

add wave -radix binary          tb_aes128_dec/aresetn
add wave -radix binary          tb_aes128_dec/aclk

add wave -radix hexadecimal     tb_aes128_dec/s_axis_tdata
add wave -radix binary          tb_aes128_dec/s_axis_tvalid
add wave -radix binary          tb_aes128_dec/s_axis_tready

add wave -radix hexadecimal     tb_aes128_dec/m_axis_tdata
add wave -radix binary          tb_aes128_dec/m_axis_tvalid
add wave -radix binary          tb_aes128_dec/m_axis_tready

# Run the simulation for the specified time
run 20ms

# Zoom out to show all waveform data
wave zoom full