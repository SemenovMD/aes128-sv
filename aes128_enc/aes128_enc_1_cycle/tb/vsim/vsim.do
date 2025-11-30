# Enable transcript logging
transcript on

# Create the work library
vlib work

# Compile the design and testbench
vlog -sv    aes128_enc/aes128_enc_1_cycle/rtl/aes128_enc_core_cluster.sv

vlog -sv    aes128_enc/aes128_enc_1_cycle/tb/tb_aes128_enc.sv

# Simulate the testbench
vsim -t 1ns -L altera_mf_ver -voptargs="+acc" tb_aes128_enc

# Add signals to the waveform window

add wave -radix binary          tb_aes128_enc/aresetn
add wave -radix binary          tb_aes128_enc/aclk

add wave -radix hexadecimal     tb_aes128_enc/s_axis_tdata
add wave -radix binary          tb_aes128_enc/s_axis_tvalid
add wave -radix binary          tb_aes128_enc/s_axis_tready

add wave -radix hexadecimal     tb_aes128_enc/m_axis_tdata
add wave -radix binary          tb_aes128_enc/m_axis_tvalid
add wave -radix binary          tb_aes128_enc/m_axis_tready

# Run the simulation for the specified time
run 20ms

# Zoom out to show all waveform data
wave zoom full