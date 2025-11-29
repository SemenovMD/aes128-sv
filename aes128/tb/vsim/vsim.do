# Enable transcript logging
transcript on

# Create the work library
vlib work

# Compile the design and testbench
vlog -sv    aes128/rtl/aes128.sv
vlog -sv    aes128/rtl/mix_colums_rom.sv

vlog -sv    aes128/tb/tb_aes128.sv

# Simulate the testbench
vsim -t 1ns -L altera_mf_ver -voptargs="+acc" tb_aes128

# Add signals to the waveform window

add wave -radix binary          tb_aes128/aresetn
add wave -radix binary          tb_aes128/aclk

add wave -radix hexadecimal     tb_aes128/s_axis_tdata
add wave -radix binary          tb_aes128/s_axis_tvalid
add wave -radix binary          tb_aes128/s_axis_tready

add wave -radix hexadecimal     tb_aes128/m_axis_tdata
add wave -radix binary          tb_aes128/m_axis_tvalid
add wave -radix binary          tb_aes128/m_axis_tready

add wave -radix hexadecimal     tb_aes128/dut/rd_data_0_0E
add wave -radix hexadecimal     tb_aes128/dut/rd_data_0_0B
add wave -radix hexadecimal     tb_aes128/dut/rd_data_0_0D
add wave -radix hexadecimal     tb_aes128/dut/rd_data_0_09

add wave -radix hexadecimal     tb_aes128/dut/rd_data_1_0E
add wave -radix hexadecimal     tb_aes128/dut/rd_data_1_0B
add wave -radix hexadecimal     tb_aes128/dut/rd_data_1_0D
add wave -radix hexadecimal     tb_aes128/dut/rd_data_1_09

add wave -radix hexadecimal     tb_aes128/dut/rd_data_2_0E
add wave -radix hexadecimal     tb_aes128/dut/rd_data_2_0B
add wave -radix hexadecimal     tb_aes128/dut/rd_data_2_0D
add wave -radix hexadecimal     tb_aes128/dut/rd_data_2_09

add wave -radix hexadecimal     tb_aes128/dut/rd_data_3_0E
add wave -radix hexadecimal     tb_aes128/dut/rd_data_3_0B
add wave -radix hexadecimal     tb_aes128/dut/rd_data_3_0D
add wave -radix hexadecimal     tb_aes128/dut/rd_data_3_09

add wave -radix hexadecimal     tb_aes128/dut/data_buf
add wave -radix binary          tb_aes128/dut/state
add wave -radix unsigned        tb_aes128/dut/count

# Run the simulation for the specified time
run 20ms

# Zoom out to show all waveform data
wave zoom full