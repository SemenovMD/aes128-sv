module aes128_enc_core

(
    input   logic           aclk,
    input   logic           aresetn,

    input   logic   [127:0] key [0:10],

    input   logic   [127:0] s_axis_tdata,
    input   logic           s_axis_tvalid,
    output  logic           s_axis_tready,

    output  logic   [127:0] m_axis_tdata,
    output  logic           m_axis_tvalid,
    input   logic           m_axis_tready
);

    localparam logic [7:0] SBOX [0:255] = '{
        //  0      1      2      3      4      5      6      7      8      9      A      B      C      D      E      F
        8'h63, 8'h7C, 8'h77, 8'h7B, 8'hF2, 8'h6B, 8'h6F, 8'hC5, 8'h30, 8'h01, 8'h67, 8'h2B, 8'hFE, 8'hD7, 8'hAB, 8'h76, // 0
        8'hCA, 8'h82, 8'hC9, 8'h7D, 8'hFA, 8'h59, 8'h47, 8'hF0, 8'hAD, 8'hD4, 8'hA2, 8'hAF, 8'h9C, 8'hA4, 8'h72, 8'hC0, // 1
        8'hB7, 8'hFD, 8'h93, 8'h26, 8'h36, 8'h3F, 8'hF7, 8'hCC, 8'h34, 8'hA5, 8'hE5, 8'hF1, 8'h71, 8'hD8, 8'h31, 8'h15, // 2
        8'h04, 8'hC7, 8'h23, 8'hC3, 8'h18, 8'h96, 8'h05, 8'h9A, 8'h07, 8'h12, 8'h80, 8'hE2, 8'hEB, 8'h27, 8'hB2, 8'h75, // 3
        8'h09, 8'h83, 8'h2C, 8'h1A, 8'h1B, 8'h6E, 8'h5A, 8'hA0, 8'h52, 8'h3B, 8'hD6, 8'hB3, 8'h29, 8'hE3, 8'h2F, 8'h84, // 4
        8'h53, 8'hD1, 8'h00, 8'hED, 8'h20, 8'hFC, 8'hB1, 8'h5B, 8'h6A, 8'hCB, 8'hBE, 8'h39, 8'h4A, 8'h4C, 8'h58, 8'hCF, // 5
        8'hD0, 8'hEF, 8'hAA, 8'hFB, 8'h43, 8'h4D, 8'h33, 8'h85, 8'h45, 8'hF9, 8'h02, 8'h7F, 8'h50, 8'h3C, 8'h9F, 8'hA8, // 6
        8'h51, 8'hA3, 8'h40, 8'h8F, 8'h92, 8'h9D, 8'h38, 8'hF5, 8'hBC, 8'hB6, 8'hDA, 8'h21, 8'h10, 8'hFF, 8'hF3, 8'hD2, // 7
        8'hCD, 8'h0C, 8'h13, 8'hEC, 8'h5F, 8'h97, 8'h44, 8'h17, 8'hC4, 8'hA7, 8'h7E, 8'h3D, 8'h64, 8'h5D, 8'h19, 8'h73, // 8
        8'h60, 8'h81, 8'h4F, 8'hDC, 8'h22, 8'h2A, 8'h90, 8'h88, 8'h46, 8'hEE, 8'hB8, 8'h14, 8'hDE, 8'h5E, 8'h0B, 8'hDB, // 9
        8'hE0, 8'h32, 8'h3A, 8'h0A, 8'h49, 8'h06, 8'h24, 8'h5C, 8'hC2, 8'hD3, 8'hAC, 8'h62, 8'h91, 8'h95, 8'hE4, 8'h79, // A
        8'hE7, 8'hC8, 8'h37, 8'h6D, 8'h8D, 8'hD5, 8'h4E, 8'hA9, 8'h6C, 8'h56, 8'hF4, 8'hEA, 8'h65, 8'h7A, 8'hAE, 8'h08, // B
        8'hBA, 8'h78, 8'h25, 8'h2E, 8'h1C, 8'hA6, 8'hB4, 8'hC6, 8'hE8, 8'hDD, 8'h74, 8'h1F, 8'h4B, 8'hBD, 8'h8B, 8'h8A, // C
        8'h70, 8'h3E, 8'hB5, 8'h66, 8'h48, 8'h03, 8'hF6, 8'h0E, 8'h61, 8'h35, 8'h57, 8'hB9, 8'h86, 8'hC1, 8'h1D, 8'h9E, // D
        8'hE1, 8'hF8, 8'h98, 8'h11, 8'h69, 8'hD9, 8'h8E, 8'h94, 8'h9B, 8'h1E, 8'h87, 8'hE9, 8'hCE, 8'h55, 8'h28, 8'hDF, // E
        8'h8C, 8'hA1, 8'h89, 8'h0D, 8'hBF, 8'hE6, 8'h42, 8'h68, 8'h41, 8'h99, 8'h2D, 8'h0F, 8'hB0, 8'h54, 8'hBB, 8'h16  // F
    };

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

    logic   [127:0] data_buf;
    logic   [3:0]   count;

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

    //////////////////////////////////////////////////////////////////////////////////////////
    // FSM
    //////////////////////////////////////////////////////////////////////////////////////////
    typedef enum logic [2:0] 
    {
        START,
        HAND_S_AXIS,
        ADD_ROUND_KEY_0,
        SUB_BYTES,
        SHIFT_ROWS,
        MIX_COLUMNS,
        ADD_ROUND_KEY_1,
        HAND_M_AXIS
    } state_type;

    state_type state;

    always_ff @(posedge aclk) begin
        if (!aresetn) begin
            state <= START;
            count <= 4'd0;
            s_axis_tready <= 1'd0;
            m_axis_tvalid <= 1'd0;
        end else begin
            case (state)
                START:
                    begin
                        state <= HAND_S_AXIS;
                        s_axis_tready <= 1'd1;
                    end
                HAND_S_AXIS:
                    begin
                        if (s_axis_tvalid) begin
                            state <= ADD_ROUND_KEY_0;
                            data_buf <= s_axis_tdata;
                            s_axis_tready <= 1'd0;
                        end

                        m_axis_tvalid <= 1'd0;
                    end
                ADD_ROUND_KEY_0:
                    begin
                        state <= SUB_BYTES;
                        data_buf <= data_buf ^ key[count];
                        count <= count + 1'd1;
                    end
                SUB_BYTES:
                    begin
                        state <= SHIFT_ROWS;
                        data_buf[127:120] <= SBOX[data_buf[127:120]];
                        data_buf[119:112] <= SBOX[data_buf[119:112]];
                        data_buf[111:104] <= SBOX[data_buf[111:104]];
                        data_buf[103:96]  <= SBOX[data_buf[103:96]];
                        data_buf[95:88]   <= SBOX[data_buf[95:88]];
                        data_buf[87:80]   <= SBOX[data_buf[87:80]];
                        data_buf[79:72]   <= SBOX[data_buf[79:72]];
                        data_buf[71:64]   <= SBOX[data_buf[71:64]];
                        data_buf[63:56]   <= SBOX[data_buf[63:56]];
                        data_buf[55:48]   <= SBOX[data_buf[55:48]];
                        data_buf[47:40]   <= SBOX[data_buf[47:40]];
                        data_buf[39:32]   <= SBOX[data_buf[39:32]];
                        data_buf[31:24]   <= SBOX[data_buf[31:24]];
                        data_buf[23:16]   <= SBOX[data_buf[23:16]];
                        data_buf[15:8]    <= SBOX[data_buf[15:8]];
                        data_buf[7:0]     <= SBOX[data_buf[7:0]];
                    end
                SHIFT_ROWS:
                    begin
                        if (count != 4'd10) begin
                            state <= MIX_COLUMNS;
                        end else begin
                            state <= ADD_ROUND_KEY_1;
                        end

                        data_buf[127:96] <= {data_buf[127:120], data_buf[87:80],   data_buf[47:40],   data_buf[7:0]};
                        data_buf[95:64]  <= {data_buf[95:88],   data_buf[55:48],   data_buf[15:8],    data_buf[103:96]};
                        data_buf[63:32]  <= {data_buf[63:56],   data_buf[23:16],   data_buf[111:104], data_buf[71:64]};
                        data_buf[31:0]   <= {data_buf[31:24],   data_buf[119:112], data_buf[79:72],   data_buf[39:32]};
                    end
                MIX_COLUMNS:
                    begin
                        state <= ADD_ROUND_KEY_1;
                        
                        data_buf[127:120] <= (MULT_02[rd_addr_0_02]  ^ MULT_03[rd_addr_0_03])  ^ (rd_addr_0_01  ^ rd_addr_0_01_2);
                        data_buf[119:112] <= (MULT_02[rd_addr_1_02]  ^ MULT_03[rd_addr_1_03])  ^ (rd_addr_1_01  ^ rd_addr_1_01_2);
                        data_buf[111:104] <= (MULT_02[rd_addr_2_02]  ^ MULT_03[rd_addr_2_03])  ^ (rd_addr_2_01  ^ rd_addr_2_01_2);
                        data_buf[103:96]  <= (MULT_03[rd_addr_3_03]  ^ MULT_02[rd_addr_3_02])  ^ (rd_addr_3_01  ^ rd_addr_3_01_2);

                        data_buf[95:88]   <= (MULT_02[rd_addr_4_02]  ^ MULT_03[rd_addr_4_03])  ^ (rd_addr_4_01  ^ rd_addr_4_01_2);
                        data_buf[87:80]   <= (MULT_02[rd_addr_5_02]  ^ MULT_03[rd_addr_5_03])  ^ (rd_addr_5_01  ^ rd_addr_5_01_2);
                        data_buf[79:72]   <= (MULT_02[rd_addr_6_02]  ^ MULT_03[rd_addr_6_03])  ^ (rd_addr_6_01  ^ rd_addr_6_01_2);
                        data_buf[71:64]   <= (MULT_03[rd_addr_7_03]  ^ MULT_02[rd_addr_7_02])  ^ (rd_addr_7_01  ^ rd_addr_7_01_2);

                        data_buf[63:56]   <= (MULT_02[rd_addr_8_02]  ^ MULT_03[rd_addr_8_03])  ^ (rd_addr_8_01  ^ rd_addr_8_01_2);
                        data_buf[55:48]   <= (MULT_02[rd_addr_9_02]  ^ MULT_03[rd_addr_9_03])  ^ (rd_addr_9_01  ^ rd_addr_9_01_2);
                        data_buf[47:40]   <= (MULT_02[rd_addr_10_02] ^ MULT_03[rd_addr_10_03]) ^ (rd_addr_10_01 ^ rd_addr_10_01_2);
                        data_buf[39:32]   <= (MULT_03[rd_addr_11_03] ^ MULT_02[rd_addr_11_02]) ^ (rd_addr_11_01 ^ rd_addr_11_01_2);

                        data_buf[31:24]   <= (MULT_02[rd_addr_12_02] ^ MULT_03[rd_addr_12_03]) ^ (rd_addr_12_01 ^ rd_addr_12_01_2);
                        data_buf[23:16]   <= (MULT_02[rd_addr_13_02] ^ MULT_03[rd_addr_13_03]) ^ (rd_addr_13_01 ^ rd_addr_13_01_2);
                        data_buf[15:8]    <= (MULT_02[rd_addr_14_02] ^ MULT_03[rd_addr_14_03]) ^ (rd_addr_14_01 ^ rd_addr_14_01_2);
                        data_buf[7:0]     <= (MULT_03[rd_addr_15_03] ^ MULT_02[rd_addr_15_02]) ^ (rd_addr_15_01 ^ rd_addr_15_01_2);
                    end
                ADD_ROUND_KEY_1:
                    begin
                        if (count != 4'd10) begin
                            state <= SUB_BYTES;
                            count <= count + 1'd1;
                        end else begin
                            state <= HAND_M_AXIS;
                            count <= 4'd0;
                        end

                        data_buf <= data_buf ^ key[count];
                    end
                HAND_M_AXIS:
                    begin
                        m_axis_tvalid <= 1'd1;
                        m_axis_tdata <= data_buf;

                        if (m_axis_tready) begin
                            state <= HAND_S_AXIS;
                            s_axis_tready <= 1'd1;
                        end
                    end
            endcase
        end
    end

    always_comb begin
        rd_addr_0_02    = data_buf[127:120];
        rd_addr_0_03    = data_buf[119:112];
        rd_addr_0_01    = data_buf[111:104];
        rd_addr_0_01_2  = data_buf[103:96];

        rd_addr_1_02    = data_buf[119:112];
        rd_addr_1_03    = data_buf[111:104];
        rd_addr_1_01    = data_buf[127:120];
        rd_addr_1_01_2  = data_buf[103:96];

        rd_addr_2_02    = data_buf[111:104];
        rd_addr_2_03    = data_buf[103:96];
        rd_addr_2_01    = data_buf[127:120];
        rd_addr_2_01_2  = data_buf[119:112];

        rd_addr_3_03    = data_buf[127:120];
        rd_addr_3_02    = data_buf[103:96];
        rd_addr_3_01    = data_buf[119:112];
        rd_addr_3_01_2  = data_buf[111:104];

        rd_addr_4_02    = data_buf[95:88];
        rd_addr_4_03    = data_buf[87:80];
        rd_addr_4_01    = data_buf[79:72];
        rd_addr_4_01_2  = data_buf[71:64];

        rd_addr_5_02    = data_buf[87:80];
        rd_addr_5_03    = data_buf[79:72];
        rd_addr_5_01    = data_buf[95:88];
        rd_addr_5_01_2  = data_buf[71:64];

        rd_addr_6_02    = data_buf[79:72];
        rd_addr_6_03    = data_buf[71:64];
        rd_addr_6_01    = data_buf[95:88];
        rd_addr_6_01_2  = data_buf[87:80];

        rd_addr_7_03    = data_buf[95:88];
        rd_addr_7_02    = data_buf[71:64];
        rd_addr_7_01    = data_buf[87:80];
        rd_addr_7_01_2  = data_buf[79:72];

        rd_addr_8_02    = data_buf[63:56];
        rd_addr_8_03    = data_buf[55:48];
        rd_addr_8_01    = data_buf[47:40];
        rd_addr_8_01_2  = data_buf[39:32];

        rd_addr_9_02    = data_buf[55:48];
        rd_addr_9_03    = data_buf[47:40];
        rd_addr_9_01    = data_buf[63:56];
        rd_addr_9_01_2  = data_buf[39:32];

        rd_addr_10_02   = data_buf[47:40];
        rd_addr_10_03   = data_buf[39:32];
        rd_addr_10_01   = data_buf[63:56];
        rd_addr_10_01_2 = data_buf[55:48];

        rd_addr_11_03   = data_buf[63:56];
        rd_addr_11_02   = data_buf[39:32];
        rd_addr_11_01   = data_buf[55:48];
        rd_addr_11_01_2 = data_buf[47:40];

        rd_addr_12_02   = data_buf[31:24];
        rd_addr_12_03   = data_buf[23:16];
        rd_addr_12_01   = data_buf[15:8];
        rd_addr_12_01_2 = data_buf[7:0];

        rd_addr_13_02   = data_buf[23:16];
        rd_addr_13_03   = data_buf[15:8];
        rd_addr_13_01   = data_buf[31:24];
        rd_addr_13_01_2 = data_buf[7:0];

        rd_addr_14_02   = data_buf[15:8];
        rd_addr_14_03   = data_buf[7:0];
        rd_addr_14_01   = data_buf[31:24];
        rd_addr_14_01_2 = data_buf[23:16];

        rd_addr_15_03   = data_buf[31:24];
        rd_addr_15_02   = data_buf[7:0];
        rd_addr_15_01   = data_buf[23:16];
        rd_addr_15_01_2 = data_buf[15:8];
    end

endmodule