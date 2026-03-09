# Enable transcript logging
transcript on

# Create the work library
vlib work

# Compile the design and testbench
vlog -sv    aes128_pipeline/aes128_dec_pipeline/rtl/aes128_dec_pp.sv
vlog -sv    aes128_pipeline/aes128_dec_pipeline/rtl/stage_dec_hand_m_axis.sv
vlog -sv    aes128_pipeline/aes128_dec_pipeline/rtl/stage_dec_hand_s_axis.sv
vlog -sv    aes128_pipeline/aes128_dec_pipeline/rtl/round_stage_dec.sv
vlog -sv    aes128_pipeline/aes128_dec_pipeline/rtl/round_stage_dec_final.sv
vlog -sv    aes128_pipeline/aes128_dec_pipeline/rtl/stage_dec_add_round_key.sv
vlog -sv    aes128_pipeline/aes128_dec_pipeline/rtl/stage_dec_mix_columns.sv
vlog -sv    aes128_pipeline/aes128_dec_pipeline/rtl/stage_dec_shift_rows.sv
vlog -sv    aes128_pipeline/aes128_dec_pipeline/rtl/stage_dec_sub_bytes.sv
vlog -sv    aes128_pipeline/aes128_dec_pipeline/tb/tb_aes128_dec.sv

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