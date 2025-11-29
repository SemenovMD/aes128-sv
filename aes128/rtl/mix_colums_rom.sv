module mix_columns_rom 
(
    input   logic           aclk,
    input   logic           aresetn,

    // MULT 0E
    input   logic   [7:0]   rd_addr_0_0E,
    input   logic   [7:0]   rd_addr_1_0E,
    input   logic   [7:0]   rd_addr_2_0E,
    input   logic   [7:0]   rd_addr_3_0E,
    output  logic   [7:0]   rd_data_0_0E,
    output  logic   [7:0]   rd_data_1_0E,
    output  logic   [7:0]   rd_data_2_0E,
    output  logic   [7:0]   rd_data_3_0E,

    // MULT 0B
    input   logic   [7:0]   rd_addr_0_0B,
    input   logic   [7:0]   rd_addr_1_0B,
    input   logic   [7:0]   rd_addr_2_0B,
    input   logic   [7:0]   rd_addr_3_0B,
    output  logic   [7:0]   rd_data_0_0B,
    output  logic   [7:0]   rd_data_1_0B,
    output  logic   [7:0]   rd_data_2_0B,
    output  logic   [7:0]   rd_data_3_0B,

    // MULT 0D
    input   logic   [7:0]   rd_addr_0_0D,
    input   logic   [7:0]   rd_addr_1_0D,
    input   logic   [7:0]   rd_addr_2_0D,
    input   logic   [7:0]   rd_addr_3_0D,
    output  logic   [7:0]   rd_data_0_0D,
    output  logic   [7:0]   rd_data_1_0D,
    output  logic   [7:0]   rd_data_2_0D,
    output  logic   [7:0]   rd_data_3_0D,

    // MULT 09
    input   logic   [7:0]   rd_addr_0_09,
    input   logic   [7:0]   rd_addr_1_09,
    input   logic   [7:0]   rd_addr_2_09,
    input   logic   [7:0]   rd_addr_3_09,
    output  logic   [7:0]   rd_data_0_09,
    output  logic   [7:0]   rd_data_1_09,
    output  logic   [7:0]   rd_data_2_09,
    output  logic   [7:0]   rd_data_3_09
);

    logic   [7:0]   mem_0E_0  [0:255];
    logic   [7:0]   mem_0E_1  [0:255];
    logic   [7:0]   mem_0B_0  [0:255];
    logic   [7:0]   mem_0B_1  [0:255];
    logic   [7:0]   mem_0D_0  [0:255];
    logic   [7:0]   mem_0D_1  [0:255];
    logic   [7:0]   mem_09_0  [0:255];
    logic   [7:0]   mem_09_1  [0:255];

    initial begin
        $readmemh("mult_0E.mem", mem_0E_0);
        $readmemh("mult_0E.mem", mem_0E_1);
        $readmemh("mult_0B.mem", mem_0B_0);
        $readmemh("mult_0B.mem", mem_0B_1);
        $readmemh("mult_0D.mem", mem_0D_0);
        $readmemh("mult_0D.mem", mem_0D_1);
        $readmemh("mult_09.mem", mem_09_0);
        $readmemh("mult_09.mem", mem_09_1);
    end

    // 0E
    always_ff @(posedge aclk) begin
        rd_data_0_0E <= mem_0E_0[rd_addr_0_0E];
        rd_data_1_0E <= mem_0E_0[rd_addr_1_0E];
        rd_data_2_0E <= mem_0E_1[rd_addr_2_0E];
        rd_data_3_0E <= mem_0E_1[rd_addr_3_0E];
    end

    // 0B
    always_ff @(posedge aclk) begin
        rd_data_0_0B <= mem_0B_0[rd_addr_0_0B];
        rd_data_1_0B <= mem_0B_0[rd_addr_1_0B];
        rd_data_2_0B <= mem_0B_1[rd_addr_2_0B];
        rd_data_3_0B <= mem_0B_1[rd_addr_3_0B];
    end

    // 0D
    always_ff @(posedge aclk) begin
        rd_data_0_0D <= mem_0D_0[rd_addr_0_0D];
        rd_data_1_0D <= mem_0D_0[rd_addr_1_0D];
        rd_data_2_0D <= mem_0D_1[rd_addr_2_0D];
        rd_data_3_0D <= mem_0D_1[rd_addr_3_0D];
    end

    // 09
    always_ff @(posedge aclk) begin
        rd_data_0_09 <= mem_09_0[rd_addr_0_09];
        rd_data_1_09 <= mem_09_0[rd_addr_1_09];
        rd_data_2_09 <= mem_09_1[rd_addr_2_09];
        rd_data_3_09 <= mem_09_1[rd_addr_3_09];
    end

endmodule