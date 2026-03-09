# Variables
SIM_DEC_CORE     = aes128_core/aes128_dec_core/tb/vsim/vsim.do
SIM_ENC_CORE     = aes128_core/aes128_enc_core/tb/vsim/vsim.do

SIM_DEC_PIPELINE = aes128_pipeline/aes128_dec_pipeline/tb/vsim/vsim.do
SIM_ENC_PIPELINE = aes128_pipeline/aes128_enc_pipeline/tb/vsim/vsim.do

# Targets
all: sim_dec_pipeline

sim_dec_core:
	@echo "Running simulation..."
	vsim -do $(SIM_DEC_CORE)
	@echo "Simulation completed"
	
sim_enc_core:
	@echo "Running simulation..."
	vsim -do $(SIM_ENC_CORE)
	@echo "Simulation completed"

sim_dec_pipeline:
	@echo "Running simulation..."
	vsim -do $(SIM_DEC_PIPELINE)
	@echo "Simulation completed"

sim_enc_pipeline:
	@echo "Running simulation..."
	vsim -do $(SIM_ENC_PIPELINE)
	@echo "Simulation completed"
	
clean:
	@echo "Cleaning up..."
	rm -rf work
	rm -f transcript
	rm -f vsim.wlf
	@echo "Clean completed."

.PHONY: all sim_dec_core sim_enc_core sim_dec_pipeline sim_enc_pipeline clean
