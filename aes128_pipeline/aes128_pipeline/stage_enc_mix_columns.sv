module stage_enc_mix_columns

(
    input   logic           aclk,
    input   logic           aresetn,
    input   logic           en,

    input   logic   [127:0] data_in,
    input   logic           valid_in,

    output  logic   [127:0] data_out,
    output  logic           valid_out
);

    localparam logic [7:0] MULT_02 [0:255] = '{
        //  0      1      2      3      4      5      6      7      8      9      A      B      C      D      E      F
        8'h00, 8'h02, 8'h04, 8'h06, 8'h08, 8'h0A, 8'h0C, 8'h0E, 8'h10, 8'h12, 8'h14, 8'h16, 8'h18, 8'h1A, 8'h1C, 8'h1E, // 0
        8'h20, 8'h22, 8'h24, 8'h26, 8'h28, 8'h2A, 8'h2C, 8'h2E, 8'h30, 8'h32, 8'h34, 8'h36, 8'h38, 8'h3A, 8'h3C, 8'h3E, // 1
        8'h40, 8'h42, 8'h44, 8'h46, 8'h48, 8'h4A, 8'h4C, 8'h4E, 8'h50, 8'h52, 8'h54, 8'h56, 8'h58, 8'h5A, 8'h5C, 8'h5E, // 2
        8'h60, 8'h62, 8'h64, 8'h66, 8'h68, 8'h6A, 8'h6C, 8'h6E, 8'h70, 8'h72, 8'h74, 8'h76, 8'h78, 8'h7A, 8'h7C, 8'h7E, // 3
        8'h80, 8'h82, 8'h84, 8'h86, 8'h88, 8'h8A, 8'h8C, 8'h8E, 8'h90, 8'h92, 8'h94, 8'h96, 8'h98, 8'h9A, 8'h9C, 8'h9E, // 4
        8'hA0, 8'hA2, 8'hA4, 8'hA6, 8'hA8, 8'hAA, 8'hAC, 8'hAE, 8'hB0, 8'hB2, 8'hB4, 8'hB6, 8'hB8, 8'hBA, 8'hBC, 8'hBE, // 5
        8'hC0, 8'hC2, 8'hC4, 8'hC6, 8'hC8, 8'hCA, 8'hCC, 8'hCE, 8'hD0, 8'hD2, 8'hD4, 8'hD6, 8'hD8, 8'hDA, 8'hDC, 8'hDE, // 6
        8'hE0, 8'hE2, 8'hE4, 8'hE6, 8'hE8, 8'hEA, 8'hEC, 8'hEE, 8'hF0, 8'hF2, 8'hF4, 8'hF6, 8'hF8, 8'hFA, 8'hFC, 8'hFE, // 7
        8'h1B, 8'h19, 8'h1F, 8'h1D, 8'h13, 8'h11, 8'h17, 8'h15, 8'h0B, 8'h09, 8'h0F, 8'h0D, 8'h03, 8'h01, 8'h07, 8'h05, // 8
        8'h3B, 8'h39, 8'h3F, 8'h3D, 8'h33, 8'h31, 8'h37, 8'h35, 8'h2B, 8'h29, 8'h2F, 8'h2D, 8'h23, 8'h21, 8'h27, 8'h25, // 9
        8'h5B, 8'h59, 8'h5F, 8'h5D, 8'h53, 8'h51, 8'h57, 8'h55, 8'h4B, 8'h49, 8'h4F, 8'h4D, 8'h43, 8'h41, 8'h47, 8'h45, // A
        8'h7B, 8'h79, 8'h7F, 8'h7D, 8'h73, 8'h71, 8'h77, 8'h75, 8'h6B, 8'h69, 8'h6F, 8'h6D, 8'h63, 8'h61, 8'h67, 8'h65, // B
        8'h9B, 8'h99, 8'h9F, 8'h9D, 8'h93, 8'h91, 8'h97, 8'h95, 8'h8B, 8'h89, 8'h8F, 8'h8D, 8'h83, 8'h81, 8'h87, 8'h85, // C
        8'hBB, 8'hB9, 8'hBF, 8'hBD, 8'hB3, 8'hB1, 8'hB7, 8'hB5, 8'hAB, 8'hA9, 8'hAF, 8'hAD, 8'hA3, 8'hA1, 8'hA7, 8'hA5, // D
        8'hDB, 8'hD9, 8'hDF, 8'hDD, 8'hD3, 8'hD1, 8'hD7, 8'hD5, 8'hCB, 8'hC9, 8'hCF, 8'hCD, 8'hC3, 8'hC1, 8'hC7, 8'hC5, // E
        8'hFB, 8'hF9, 8'hFF, 8'hFD, 8'hF3, 8'hF1, 8'hF7, 8'hF5, 8'hEB, 8'hE9, 8'hEF, 8'hED, 8'hE3, 8'hE1, 8'hE7, 8'hE5  // F
    };

    localparam logic [7:0] MULT_03 [0:255] = '{
        //  0      1      2      3      4      5      6      7      8      9      A      B      C      D      E      F
        8'h00, 8'h03, 8'h06, 8'h05, 8'h0C, 8'h0F, 8'h0A, 8'h09, 8'h18, 8'h1B, 8'h1E, 8'h1D, 8'h14, 8'h17, 8'h12, 8'h11, // 0
        8'h30, 8'h33, 8'h36, 8'h35, 8'h3C, 8'h3F, 8'h3A, 8'h39, 8'h28, 8'h2B, 8'h2E, 8'h2D, 8'h24, 8'h27, 8'h22, 8'h21, // 1
        8'h60, 8'h63, 8'h66, 8'h65, 8'h6C, 8'h6F, 8'h6A, 8'h69, 8'h78, 8'h7B, 8'h7E, 8'h7D, 8'h74, 8'h77, 8'h72, 8'h71, // 2
        8'h50, 8'h53, 8'h56, 8'h55, 8'h5C, 8'h5F, 8'h5A, 8'h59, 8'h48, 8'h4B, 8'h4E, 8'h4D, 8'h44, 8'h47, 8'h42, 8'h41, // 3
        8'hC0, 8'hC3, 8'hC6, 8'hC5, 8'hCC, 8'hCF, 8'hCA, 8'hC9, 8'hD8, 8'hDB, 8'hDE, 8'hDD, 8'hD4, 8'hD7, 8'hD2, 8'hD1, // 4
        8'hF0, 8'hF3, 8'hF6, 8'hF5, 8'hFC, 8'hFF, 8'hFA, 8'hF9, 8'hE8, 8'hEB, 8'hEE, 8'hED, 8'hE4, 8'hE7, 8'hE2, 8'hE1, // 5
        8'hA0, 8'hA3, 8'hA6, 8'hA5, 8'hAC, 8'hAF, 8'hAA, 8'hA9, 8'hB8, 8'hBB, 8'hBE, 8'hBD, 8'hB4, 8'hB7, 8'hB2, 8'hB1, // 6
        8'h90, 8'h93, 8'h96, 8'h95, 8'h9C, 8'h9F, 8'h9A, 8'h99, 8'h88, 8'h8B, 8'h8E, 8'h8D, 8'h84, 8'h87, 8'h82, 8'h81, // 7
        8'h9B, 8'h98, 8'h9D, 8'h9E, 8'h97, 8'h94, 8'h91, 8'h92, 8'h83, 8'h80, 8'h85, 8'h86, 8'h8F, 8'h8C, 8'h89, 8'h8A, // 8
        8'hAB, 8'hA8, 8'hAD, 8'hAE, 8'hA7, 8'hA4, 8'hA1, 8'hA2, 8'hB3, 8'hB0, 8'hB5, 8'hB6, 8'hBF, 8'hBC, 8'hB9, 8'hBA, // 9
        8'hFB, 8'hF8, 8'hFD, 8'hFE, 8'hF7, 8'hF4, 8'hF1, 8'hF2, 8'hE3, 8'hE0, 8'hE5, 8'hE6, 8'hEF, 8'hEC, 8'hE9, 8'hEA, // A
        8'hCB, 8'hC8, 8'hCD, 8'hCE, 8'hC7, 8'hC4, 8'hC1, 8'hC2, 8'hD3, 8'hD0, 8'hD5, 8'hD6, 8'hDF, 8'hDC, 8'hD9, 8'hDA, // B
        8'h5B, 8'h58, 8'h5D, 8'h5E, 8'h57, 8'h54, 8'h51, 8'h52, 8'h43, 8'h40, 8'h45, 8'h46, 8'h4F, 8'h4C, 8'h49, 8'h4A, // C
        8'h6B, 8'h68, 8'h6D, 8'h6E, 8'h67, 8'h64, 8'h61, 8'h62, 8'h73, 8'h70, 8'h75, 8'h76, 8'h7F, 8'h7C, 8'h79, 8'h7A, // D
        8'h3B, 8'h38, 8'h3D, 8'h3E, 8'h37, 8'h34, 8'h31, 8'h32, 8'h23, 8'h20, 8'h25, 8'h26, 8'h2F, 8'h2C, 8'h29, 8'h2A, // E
        8'h0B, 8'h08, 8'h0D, 8'h0E, 8'h07, 8'h04, 8'h01, 8'h02, 8'h13, 8'h10, 8'h15, 8'h16, 8'h1F, 8'h1C, 8'h19, 8'h1A  // F
    };

    logic   [7:0]   rd_addr_0_02,  rd_addr_0_03,  rd_addr_0_01,  rd_addr_0_01_2;
    logic   [7:0]   rd_addr_1_02,  rd_addr_1_03,  rd_addr_1_01,  rd_addr_1_01_2;
    logic   [7:0]   rd_addr_2_02,  rd_addr_2_03,  rd_addr_2_01,  rd_addr_2_01_2;
    logic   [7:0]   rd_addr_3_02,  rd_addr_3_03,  rd_addr_3_01,  rd_addr_3_01_2;
    logic   [7:0]   rd_addr_4_02,  rd_addr_4_03,  rd_addr_4_01,  rd_addr_4_01_2;
    logic   [7:0]   rd_addr_5_02,  rd_addr_5_03,  rd_addr_5_01,  rd_addr_5_01_2;
    logic   [7:0]   rd_addr_6_02,  rd_addr_6_03,  rd_addr_6_01,  rd_addr_6_01_2;
    logic   [7:0]   rd_addr_7_02,  rd_addr_7_03,  rd_addr_7_01,  rd_addr_7_01_2;
    logic   [7:0]   rd_addr_8_02,  rd_addr_8_03,  rd_addr_8_01,  rd_addr_8_01_2;
    logic   [7:0]   rd_addr_9_02,  rd_addr_9_03,  rd_addr_9_01,  rd_addr_9_01_2;
    logic   [7:0]   rd_addr_10_02, rd_addr_10_03, rd_addr_10_01, rd_addr_10_01_2;
    logic   [7:0]   rd_addr_11_02, rd_addr_11_03, rd_addr_11_01, rd_addr_11_01_2;
    logic   [7:0]   rd_addr_12_02, rd_addr_12_03, rd_addr_12_01, rd_addr_12_01_2;
    logic   [7:0]   rd_addr_13_02, rd_addr_13_03, rd_addr_13_01, rd_addr_13_01_2;
    logic   [7:0]   rd_addr_14_02, rd_addr_14_03, rd_addr_14_01, rd_addr_14_01_2;
    logic   [7:0]   rd_addr_15_02, rd_addr_15_03, rd_addr_15_01, rd_addr_15_01_2;

    always_ff @(posedge aclk) begin
        if (!aresetn) begin
            valid_out <= 1'd0;
        end else begin
            if (en) begin
                data_out[127:120] <= (MULT_02[rd_addr_0_02]  ^ MULT_03[rd_addr_0_03])  ^ (rd_addr_0_01  ^ rd_addr_0_01_2);
                data_out[119:112] <= (MULT_02[rd_addr_1_02]  ^ MULT_03[rd_addr_1_03])  ^ (rd_addr_1_01  ^ rd_addr_1_01_2);
                data_out[111:104] <= (MULT_02[rd_addr_2_02]  ^ MULT_03[rd_addr_2_03])  ^ (rd_addr_2_01  ^ rd_addr_2_01_2);
                data_out[103:96]  <= (MULT_03[rd_addr_3_03]  ^ MULT_02[rd_addr_3_02])  ^ (rd_addr_3_01  ^ rd_addr_3_01_2);

                data_out[95:88]   <= (MULT_02[rd_addr_4_02]  ^ MULT_03[rd_addr_4_03])  ^ (rd_addr_4_01  ^ rd_addr_4_01_2);
                data_out[87:80]   <= (MULT_02[rd_addr_5_02]  ^ MULT_03[rd_addr_5_03])  ^ (rd_addr_5_01  ^ rd_addr_5_01_2);
                data_out[79:72]   <= (MULT_02[rd_addr_6_02]  ^ MULT_03[rd_addr_6_03])  ^ (rd_addr_6_01  ^ rd_addr_6_01_2);
                data_out[71:64]   <= (MULT_03[rd_addr_7_03]  ^ MULT_02[rd_addr_7_02])  ^ (rd_addr_7_01  ^ rd_addr_7_01_2);

                data_out[63:56]   <= (MULT_02[rd_addr_8_02]  ^ MULT_03[rd_addr_8_03])  ^ (rd_addr_8_01  ^ rd_addr_8_01_2);
                data_out[55:48]   <= (MULT_02[rd_addr_9_02]  ^ MULT_03[rd_addr_9_03])  ^ (rd_addr_9_01  ^ rd_addr_9_01_2);
                data_out[47:40]   <= (MULT_02[rd_addr_10_02] ^ MULT_03[rd_addr_10_03]) ^ (rd_addr_10_01 ^ rd_addr_10_01_2);
                data_out[39:32]   <= (MULT_03[rd_addr_11_03] ^ MULT_02[rd_addr_11_02]) ^ (rd_addr_11_01 ^ rd_addr_11_01_2);

                data_out[31:24]   <= (MULT_02[rd_addr_12_02] ^ MULT_03[rd_addr_12_03]) ^ (rd_addr_12_01 ^ rd_addr_12_01_2);
                data_out[23:16]   <= (MULT_02[rd_addr_13_02] ^ MULT_03[rd_addr_13_03]) ^ (rd_addr_13_01 ^ rd_addr_13_01_2);
                data_out[15:8]    <= (MULT_02[rd_addr_14_02] ^ MULT_03[rd_addr_14_03]) ^ (rd_addr_14_01 ^ rd_addr_14_01_2);
                data_out[7:0]     <= (MULT_03[rd_addr_15_03] ^ MULT_02[rd_addr_15_02]) ^ (rd_addr_15_01 ^ rd_addr_15_01_2);
                valid_out         <= valid_in;
            end
        end
    end

    always_comb begin
        rd_addr_0_02    = data_in[127:120];
        rd_addr_0_03    = data_in[119:112];
        rd_addr_0_01    = data_in[111:104];
        rd_addr_0_01_2  = data_in[103:96];

        rd_addr_1_02    = data_in[119:112];
        rd_addr_1_03    = data_in[111:104];
        rd_addr_1_01    = data_in[127:120];
        rd_addr_1_01_2  = data_in[103:96];

        rd_addr_2_02    = data_in[111:104];
        rd_addr_2_03    = data_in[103:96];
        rd_addr_2_01    = data_in[127:120];
        rd_addr_2_01_2  = data_in[119:112];

        rd_addr_3_03    = data_in[127:120];
        rd_addr_3_02    = data_in[103:96];
        rd_addr_3_01    = data_in[119:112];
        rd_addr_3_01_2  = data_in[111:104];

        rd_addr_4_02    = data_in[95:88];
        rd_addr_4_03    = data_in[87:80];
        rd_addr_4_01    = data_in[79:72];
        rd_addr_4_01_2  = data_in[71:64];

        rd_addr_5_02    = data_in[87:80];
        rd_addr_5_03    = data_in[79:72];
        rd_addr_5_01    = data_in[95:88];
        rd_addr_5_01_2  = data_in[71:64];

        rd_addr_6_02    = data_in[79:72];
        rd_addr_6_03    = data_in[71:64];
        rd_addr_6_01    = data_in[95:88];
        rd_addr_6_01_2  = data_in[87:80];

        rd_addr_7_03    = data_in[95:88];
        rd_addr_7_02    = data_in[71:64];
        rd_addr_7_01    = data_in[87:80];
        rd_addr_7_01_2  = data_in[79:72];

        rd_addr_8_02    = data_in[63:56];
        rd_addr_8_03    = data_in[55:48];
        rd_addr_8_01    = data_in[47:40];
        rd_addr_8_01_2  = data_in[39:32];

        rd_addr_9_02    = data_in[55:48];
        rd_addr_9_03    = data_in[47:40];
        rd_addr_9_01    = data_in[63:56];
        rd_addr_9_01_2  = data_in[39:32];

        rd_addr_10_02   = data_in[47:40];
        rd_addr_10_03   = data_in[39:32];
        rd_addr_10_01   = data_in[63:56];
        rd_addr_10_01_2 = data_in[55:48];

        rd_addr_11_03   = data_in[63:56];
        rd_addr_11_02   = data_in[39:32];
        rd_addr_11_01   = data_in[55:48];
        rd_addr_11_01_2 = data_in[47:40];

        rd_addr_12_02   = data_in[31:24];
        rd_addr_12_03   = data_in[23:16];
        rd_addr_12_01   = data_in[15:8];
        rd_addr_12_01_2 = data_in[7:0];

        rd_addr_13_02   = data_in[23:16];
        rd_addr_13_03   = data_in[15:8];
        rd_addr_13_01   = data_in[31:24];
        rd_addr_13_01_2 = data_in[7:0];

        rd_addr_14_02   = data_in[15:8];
        rd_addr_14_03   = data_in[7:0];
        rd_addr_14_01   = data_in[31:24];
        rd_addr_14_01_2 = data_in[23:16];

        rd_addr_15_03   = data_in[31:24];
        rd_addr_15_02   = data_in[7:0];
        rd_addr_15_01   = data_in[23:16];
        rd_addr_15_01_2 = data_in[15:8];
    end

endmodule