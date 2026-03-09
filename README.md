# AES-128 Core and Pipeline

The module represents a single-core or pipeline architecture `AES-128` implementation in `SystemVerilog` with an integrated `AXI-Stream` interface, optimized for deployment on `Xilinx` FPGA platforms.


## Table of Contents


- [Features](#features)
- [Parameters](#parameters)
- [Performance](#performance-and-utilization)
- [Simulation](#simulation)
- [Python Scripts Examples](#python-scripts-examples)
- [Documentation](#documentation)
- [License](#license)
- [Author](#author)


## Features


- Single-core architecture.
- Pipeline architecture.
- Key expansion block.
- Data exchange via `AXI-Stream` interface.
- Support for both encryption and decryption.
- Latency - 43 clock cycles.


## Parameters


- `START_KEY` - initial AES-128 key. Default: `128'h2B7E151628AED2A6ABF7158809CF4F3C`.
- Round keys are automatically generated in the `key_expansion` module.

## Performance and Utilization


Implementation metrics for `Xilinx Kintex-7 xc7k325tfbg676-2`.

### AES128 Decryptor

```sh
| Mode     | LUT    | FF     | BRAM | Frequency (MHz) |
|----------|--------|--------|------|-----------------|
| Core     | 1178   | 270    | 0    | 300+            |
| Pipeline | 8447   | 5300   | 0    | 300+            |
```

### AES128 Encryptor

```sh
| Mode     | LUT    | FF     | BRAM | Frequency (MHz) |
|----------|--------|--------|------|-----------------|
| Core     | 1066   | 271    | 0    | 300+            |
| Pipeline | 6722   | 4980   | 0    | 300+            |
```

### AES128 Key Expansion
```sh
| LUT    | FF     | BRAM | Frequency (MHz) |
|--------|--------|------|-----------------|
| 2392   | 1709   | 0    | 300+            |
```

To prevent BRAM usage and implement memory using distributed registers (distributed ROM), add the following constraint to your XDC file:

```tcl
set_property rom_style distributed [get_cells -hier -filter {NAME =~ **}]
```

This constraint ensures that all substitution tables (S-boxes) will be implemented on LUTs instead of BRAM blocks.


## Simulation


`QuestaSim` is used for simulation. Make sure the path to the `vsim` executable is added to your `bashrc`.

To run `AES128 Decryptor Core` simulation, execute:
```sh
make sim_dec_core
```
To run `AES128 Decryptor Pipeline` simulation, execute:
```sh
make sim_dec_pipeline
```
To run `AES128 Encryptor Core` simulation, execute:
```sh
make sim_enc_core
```
To run `AES128 Encryptor Pipeline` simulation, execute:
```sh
make sim_enc_pipeline
```
To clean simulation files, execute:
```sh
make clean
```


## Python Scripts Examples


### `calc_dec`
Calculates `AES128 decryption` operation round by round.

### `calc_enc`
Calculates `AES128 encryption` operation round by round.

### `gen_tables`
Generates test data `ciphertext.txt` and `plaintext.txt` for verification in testbench.


## Documentation

### `aes128_core_top`
Top-level module that combines single-core encryption and decryption blocks with the key expansion block.

### `aes128_enc_core`
Basic AES-128 encryption core.

### `aes128_dec_core`
Basic AES-128 decryption core.

### `aes128_pp_top`
Top-level module that combines pipeline encryption and decryption blocks with the key expansion block.

### `aes128_enc_pp`
Pipeline AES-128 encryption core.

### `aes128_dec_pp`
Pipeline AES-128 decryption core.

### `key_expansion`
Key expansion module. Generates all 11 round keys from the initial 128-bit key.

### `tb_aes128_enc`
Testbench for testing encryption modules. Generates test vectors from `plaintext.txt` and `ciphertext.txt` files, performs encryption, and compares results with expected values.

### `tb_aes128_dec`
Testbench for testing decryption modules. Generates test vectors from `ciphertext.txt` and `plaintext.txt` files, performs decryption, and compares results with expected values.


## License
[![License](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)  
The project is distributed under the [MIT](LICENSE) license.


## Author
- [Semenov Maxim](https://t.me/semenovmd) — FPGA Engineer