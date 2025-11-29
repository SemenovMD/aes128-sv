# Variables
SIM_DEC_1_CYCLE  = aes128_dec/aes128_dec_1_cycle/tb/vsim/vsim.do
SIM_DEC_42_CYCLE = aes128_dec/aes128_dec_42_cycle/tb/vsim/vsim.do

# Targets
all: sim_dec_42_cycle

sim_dec_1_cycle:
	@echo "Running simulation..."
	vsim -do $(SIM_DEC_1_CYCLE)
	@echo "Simulation completed"

sim_dec_42_cycle:
	@echo "Running simulation..."
	vsim -do $(SIM_DEC_42_CYCLE)
	@echo "Simulation completed"
	
clean:
	@echo "Cleaning up..."
	rm -rf work
	rm -f transcript
	rm -f vsim.wlf
	@echo "Clean completed."

.PHONY: all sim_dec_1_cycle sim_dec_42_cycle clean