# Enable transcript logging
transcript on

# Create the work library
vlib work

# Compile the design and testbench
vlog -sv    aes128_pipeline/aes128_enc_pipeline/rtl/aes128_enc_pp.sv
vlog -sv    aes128_pipeline/aes128_enc_pipeline/rtl/stage_enc_hand_m_axis.sv
vlog -sv    aes128_pipeline/aes128_enc_pipeline/rtl/stage_enc_hand_s_axis.sv
vlog -sv    aes128_pipeline/aes128_enc_pipeline/rtl/round_stage_enc.sv
vlog -sv    aes128_pipeline/aes128_enc_pipeline/rtl/round_stage_enc_final.sv
vlog -sv    aes128_pipeline/aes128_enc_pipeline/rtl/stage_enc_add_round_key.sv
vlog -sv    aes128_pipeline/aes128_enc_pipeline/rtl/stage_enc_mix_columns.sv
vlog -sv    aes128_pipeline/aes128_enc_pipeline/rtl/stage_enc_shift_rows.sv
vlog -sv    aes128_pipeline/aes128_enc_pipeline/rtl/stage_enc_sub_bytes.sv
vlog -sv    aes128_pipeline/aes128_enc_pipeline/tb/tb_aes128_enc.sv

vlog -sv    aes128_pipeline/aes128_enc_pipeline/tb/tb_aes128_enc.sv

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