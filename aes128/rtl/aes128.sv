module aes128

(
    input   logic           aclk,
    input   logic           aresetn,

    input   logic   [127:0] s_axis_tdata,
    input   logic           s_axis_tvalid,
    output  logic           s_axis_tready,

    output  logic   [127:0] m_axis_tdata,
    output  logic           m_axis_tvalid,
    input   logic           m_axis_tready
);

    localparam logic [127:0] KEY [10:0] = '{
        128'h2B7E151628AED2A6ABF7158809CF4F3C, // Round 0 (initial key)
        128'hA0FAFE1788542CB123A339392A6C7605, // Round 1
        128'hF2C295F27A96B9435935807A7359F67F, // Round 2
        128'h3D80477D4716FE3E1E237E446D7A883B, // Round 3
        128'hEF44A541A8525B7FB671253BDB0BAD00, // Round 4
        128'hD4D1C6F87C839D87CAF2B8BC11F915BC, // Round 5
        128'h6D88A37A110B3EFDDBF98641CA0093FD, // Round 6
        128'h4E54F70E5F5FC9F384A64FB24EA6DC4F, // Round 7
        128'hEAD27321B58DBAD2312BF5607F8D292F, // Round 8
        128'hAC7766F319FADC2128D12941575C006E, // Round 9
        128'hD014F9A8C9EE2589E13F0CC8B6630CA6 // Round 10 (same as initial for AES-128)
    };

    localparam logic [7:0] INV_SBOX [0:255] = '{
        //  0      1      2      3      4      5      6      7      8      9      A      B      C      D      E      F
        8'h52, 8'h09, 8'h6a, 8'hd5, 8'h30, 8'h36, 8'ha5, 8'h38, 8'hbf, 8'h40, 8'ha3, 8'h9e, 8'h81, 8'hf3, 8'hd7, 8'hfb, // 0
        8'h7c, 8'he3, 8'h39, 8'h82, 8'h9b, 8'h2f, 8'hff, 8'h87, 8'h34, 8'h8e, 8'h43, 8'h44, 8'hc4, 8'hde, 8'he9, 8'hcb, // 1
        8'h54, 8'h7b, 8'h94, 8'h32, 8'ha6, 8'hc2, 8'h23, 8'h3d, 8'hee, 8'h4c, 8'h95, 8'h0b, 8'h42, 8'hfa, 8'hc3, 8'h4e, // 2
        8'h08, 8'h2e, 8'ha1, 8'h66, 8'h28, 8'hd9, 8'h24, 8'hb2, 8'h76, 8'h5b, 8'ha2, 8'h49, 8'h6d, 8'h8b, 8'hd1, 8'h25, // 3
        8'h72, 8'hf8, 8'hf6, 8'h64, 8'h86, 8'h68, 8'h98, 8'h16, 8'hd4, 8'ha4, 8'h5c, 8'hcc, 8'h5d, 8'h65, 8'hb6, 8'h92, // 4
        8'h6c, 8'h70, 8'h48, 8'h50, 8'hfd, 8'hed, 8'hb9, 8'hda, 8'h5e, 8'h15, 8'h46, 8'h57, 8'ha7, 8'h8d, 8'h9d, 8'h84, // 5
        8'h90, 8'hd8, 8'hab, 8'h00, 8'h8c, 8'hbc, 8'hd3, 8'h0a, 8'hf7, 8'he4, 8'h58, 8'h05, 8'hb8, 8'hb3, 8'h45, 8'h06, // 6
        8'hd0, 8'h2c, 8'h1e, 8'h8f, 8'hca, 8'h3f, 8'h0f, 8'h02, 8'hc1, 8'haf, 8'hbd, 8'h03, 8'h01, 8'h13, 8'h8a, 8'h6b, // 7
        8'h3a, 8'h91, 8'h11, 8'h41, 8'h4f, 8'h67, 8'hdc, 8'hea, 8'h97, 8'hf2, 8'hcf, 8'hce, 8'hf0, 8'hb4, 8'he6, 8'h73, // 8
        8'h96, 8'hac, 8'h74, 8'h22, 8'he7, 8'had, 8'h35, 8'h85, 8'he2, 8'hf9, 8'h37, 8'he8, 8'h1c, 8'h75, 8'hdf, 8'h6e, // 9
        8'h47, 8'hf1, 8'h1a, 8'h71, 8'h1d, 8'h29, 8'hc5, 8'h89, 8'h6f, 8'hb7, 8'h62, 8'h0e, 8'haa, 8'h18, 8'hbe, 8'h1b, // A
        8'hfc, 8'h56, 8'h3e, 8'h4b, 8'hc6, 8'hd2, 8'h79, 8'h20, 8'h9a, 8'hdb, 8'hc0, 8'hfe, 8'h78, 8'hcd, 8'h5a, 8'hf4, // B
        8'h1f, 8'hdd, 8'ha8, 8'h33, 8'h88, 8'h07, 8'hc7, 8'h31, 8'hb1, 8'h12, 8'h10, 8'h59, 8'h27, 8'h80, 8'hec, 8'h5f, // C
        8'h60, 8'h51, 8'h7f, 8'ha9, 8'h19, 8'hb5, 8'h4a, 8'h0d, 8'h2d, 8'he5, 8'h7a, 8'h9f, 8'h93, 8'hc9, 8'h9c, 8'hef, // D
        8'ha0, 8'he0, 8'h3b, 8'h4d, 8'hae, 8'h2a, 8'hf5, 8'hb0, 8'hc8, 8'heb, 8'hbb, 8'h3c, 8'h83, 8'h53, 8'h99, 8'h61, // E
        8'h17, 8'h2b, 8'h04, 8'h7e, 8'hba, 8'h77, 8'hd6, 8'h26, 8'he1, 8'h69, 8'h14, 8'h63, 8'h55, 8'h21, 8'h0c, 8'h7d  // F
    };

    logic   [127:0] data_buf;

    logic   [3:0]   count;

    logic   [7:0]   rd_addr_0_0E, rd_addr_0_0B, rd_addr_0_0D, rd_addr_0_09;
    logic   [7:0]   rd_addr_1_0E, rd_addr_1_0B, rd_addr_1_0D, rd_addr_1_09;
    logic   [7:0]   rd_addr_2_0E, rd_addr_2_0B, rd_addr_2_0D, rd_addr_2_09;
    logic   [7:0]   rd_addr_3_0E, rd_addr_3_0B, rd_addr_3_0D, rd_addr_3_09;
    
    logic   [7:0]   rd_data_0_0E, rd_data_0_0B, rd_data_0_0D, rd_data_0_09;
    logic   [7:0]   rd_data_1_0E, rd_data_1_0B, rd_data_1_0D, rd_data_1_09;
    logic   [7:0]   rd_data_2_0E, rd_data_2_0B, rd_data_2_0D, rd_data_2_09;
    logic   [7:0]   rd_data_3_0E, rd_data_3_0B, rd_data_3_0D, rd_data_3_09;


    mix_columns_rom rom_inst 
    (
        .aclk(aclk),
        .aresetn(aresetn),

        // MULT 0E
        .rd_addr_0_0E(rd_addr_0_0E),
        .rd_addr_1_0E(rd_addr_1_0E),
        .rd_addr_2_0E(rd_addr_2_0E),
        .rd_addr_3_0E(rd_addr_3_0E),
        .rd_data_0_0E(rd_data_0_0E),
        .rd_data_1_0E(rd_data_1_0E),
        .rd_data_2_0E(rd_data_2_0E),
        .rd_data_3_0E(rd_data_3_0E),

        // MULT 0B
        .rd_addr_0_0B(rd_addr_0_0B),
        .rd_addr_1_0B(rd_addr_1_0B),
        .rd_addr_2_0B(rd_addr_2_0B),
        .rd_addr_3_0B(rd_addr_3_0B),
        .rd_data_0_0B(rd_data_0_0B),
        .rd_data_1_0B(rd_data_1_0B),
        .rd_data_2_0B(rd_data_2_0B),
        .rd_data_3_0B(rd_data_3_0B),

        // MULT 0D
        .rd_addr_0_0D(rd_addr_0_0D),
        .rd_addr_1_0D(rd_addr_1_0D),
        .rd_addr_2_0D(rd_addr_2_0D),
        .rd_addr_3_0D(rd_addr_3_0D),
        .rd_data_0_0D(rd_data_0_0D),
        .rd_data_1_0D(rd_data_1_0D),
        .rd_data_2_0D(rd_data_2_0D),
        .rd_data_3_0D(rd_data_3_0D),

        // MULT 09
        .rd_addr_0_09(rd_addr_0_09),
        .rd_addr_1_09(rd_addr_1_09),
        .rd_addr_2_09(rd_addr_2_09),
        .rd_addr_3_09(rd_addr_3_09),
        .rd_data_0_09(rd_data_0_09),
        .rd_data_1_09(rd_data_1_09),
        .rd_data_2_09(rd_data_2_09),
        .rd_data_3_09(rd_data_3_09)
    );

    // FSM
    typedef enum logic [3:0] 
    {  
        HAND_S_AXIS,
        ADD_ROUND_KEY_0,
        INV_SHIFT_ROWS,
        INV_SUB_BYTES,
        ADD_ROUND_KEY_1,
        DELAY,
        INV_MIX_COLUMS_0,
        INV_MIX_COLUMS_1,
        INV_MIX_COLUMS_2,
        INV_MIX_COLUMS_3,
        HAND_M_AXIS
    } state_type;

    state_type state;

    always_ff @(posedge aclk) begin
        if (!aresetn) begin
            state <= HAND_S_AXIS;
            count <= 4'd0;
            s_axis_tready <= 1'd0;
            m_axis_tvalid <= 1'd0;
        end else begin
            case (state)
                HAND_S_AXIS:
                    begin
                        if (s_axis_tvalid) begin
                            state <= ADD_ROUND_KEY_0;
                            data_buf <= s_axis_tdata;
                            s_axis_tready <= 1'd1;
                        end

                        m_axis_tvalid <= 1'd0;
                    end
                ADD_ROUND_KEY_0:
                    begin
                        state <= INV_SHIFT_ROWS;
                        data_buf <= data_buf ^ KEY[count];
                        count <= count + 1'd1;
                        s_axis_tready <= 1'd0;
                    end
                INV_SHIFT_ROWS:
                    begin
                        state <= INV_SUB_BYTES;

                        data_buf[127:96] <= {data_buf[127:120], data_buf[23:16],    data_buf[47:40],    data_buf[71:64]};
                        data_buf[95:64]  <= {data_buf[95:88],   data_buf[119:112],  data_buf[15:8],     data_buf[39:32]};
                        data_buf[63:32]  <= {data_buf[63:56],   data_buf[87:80],    data_buf[111:104],  data_buf[7:0]};
                        data_buf[31:0]   <= {data_buf[31:24],   data_buf[55:48],    data_buf[79:72],    data_buf[103:96]};
                    end
                INV_SUB_BYTES:
                    begin
                        state <= ADD_ROUND_KEY_1;

                        data_buf[127:120] <= INV_SBOX[data_buf[127:120]];
                        data_buf[119:112] <= INV_SBOX[data_buf[119:112]];
                        data_buf[111:104] <= INV_SBOX[data_buf[111:104]];
                        data_buf[103:96]  <= INV_SBOX[data_buf[103:96]];
                        data_buf[95:88]   <= INV_SBOX[data_buf[95:88]];
                        data_buf[87:80]   <= INV_SBOX[data_buf[87:80]];
                        data_buf[79:72]   <= INV_SBOX[data_buf[79:72]];
                        data_buf[71:64]   <= INV_SBOX[data_buf[71:64]];
                        data_buf[63:56]   <= INV_SBOX[data_buf[63:56]];
                        data_buf[55:48]   <= INV_SBOX[data_buf[55:48]];
                        data_buf[47:40]   <= INV_SBOX[data_buf[47:40]];
                        data_buf[39:32]   <= INV_SBOX[data_buf[39:32]];
                        data_buf[31:24]   <= INV_SBOX[data_buf[31:24]];
                        data_buf[23:16]   <= INV_SBOX[data_buf[23:16]];
                        data_buf[15:8]    <= INV_SBOX[data_buf[15:8]];
                        data_buf[7:0]     <= INV_SBOX[data_buf[7:0]];
                    end
                ADD_ROUND_KEY_1:
                    begin
                        if (count != 4'd10) begin
                            count <= count + 1'd1;
                            state <= DELAY;
                        end else begin
                            count <= 4'd0;
                            state <= HAND_M_AXIS;
                        end

                        data_buf <= data_buf ^ KEY[count];
                    end
                DELAY:
                    begin
                        state <= INV_MIX_COLUMS_0;
                    end
                INV_MIX_COLUMS_0:
                    begin
                        state <= INV_MIX_COLUMS_1;
                        data_buf[127:120] <= (rd_data_0_0E ^ rd_data_0_0B) ^ (rd_data_0_0D ^ rd_data_0_09);
                        data_buf[119:112] <= (rd_data_1_09 ^ rd_data_1_0E) ^ (rd_data_1_0B ^ rd_data_1_0D);
                        data_buf[111:104] <= (rd_data_2_0D ^ rd_data_2_09) ^ (rd_data_2_0E ^ rd_data_2_0B);
                        data_buf[103:96]  <= (rd_data_3_0B ^ rd_data_3_0D) ^ (rd_data_3_09 ^ rd_data_3_0E);
                    end
                INV_MIX_COLUMS_1:
                    begin
                        state <= INV_MIX_COLUMS_2;
                        data_buf[95:88]  <= (rd_data_0_0E ^ rd_data_0_0B) ^ (rd_data_0_0D ^ rd_data_0_09);
                        data_buf[87:80]  <= (rd_data_1_09 ^ rd_data_1_0E) ^ (rd_data_1_0B ^ rd_data_1_0D);
                        data_buf[79:72]  <= (rd_data_2_0D ^ rd_data_2_09) ^ (rd_data_2_0E ^ rd_data_2_0B);
                        data_buf[71:64]  <= (rd_data_3_0B ^ rd_data_3_0D) ^ (rd_data_3_09 ^ rd_data_3_0E);
                    end
                INV_MIX_COLUMS_2:
                    begin
                        state <= INV_MIX_COLUMS_3;
                        data_buf[63:56]  <= (rd_data_0_0E ^ rd_data_0_0B) ^ (rd_data_0_0D ^ rd_data_0_09);
                        data_buf[55:48]  <= (rd_data_1_09 ^ rd_data_1_0E) ^ (rd_data_1_0B ^ rd_data_1_0D);
                        data_buf[47:40]  <= (rd_data_2_0D ^ rd_data_2_09) ^ (rd_data_2_0E ^ rd_data_2_0B);
                        data_buf[39:32]  <= (rd_data_3_0B ^ rd_data_3_0D) ^ (rd_data_3_09 ^ rd_data_3_0E);
                    end
                INV_MIX_COLUMS_3:
                    begin
                        state <= INV_SHIFT_ROWS;
                        data_buf[31:24]  <= (rd_data_0_0E ^ rd_data_0_0B) ^ (rd_data_0_0D ^ rd_data_0_09);
                        data_buf[23:16]  <= (rd_data_1_09 ^ rd_data_1_0E) ^ (rd_data_1_0B ^ rd_data_1_0D);
                        data_buf[15:8]   <= (rd_data_2_0D ^ rd_data_2_09) ^ (rd_data_2_0E ^ rd_data_2_0B);
                        data_buf[7:0]    <= (rd_data_3_0B ^ rd_data_3_0D) ^ (rd_data_3_09 ^ rd_data_3_0E);
                    end
                HAND_M_AXIS:
                    begin
                        m_axis_tvalid <= 1'd1;
                        m_axis_tdata <= data_buf;

                        if (m_axis_tready) begin
                            state <= HAND_S_AXIS;
                        end
                    end
            endcase
        end
    end

    always_comb begin
        case (state)
            ADD_ROUND_KEY_1:
                begin
                    rd_addr_0_0E = data_buf[127:120];
                    rd_addr_0_0B = data_buf[119:112];
                    rd_addr_0_0D = data_buf[111:104];
                    rd_addr_0_09 = data_buf[103:96];
                    rd_addr_1_09 = data_buf[127:120];
                    rd_addr_1_0E = data_buf[119:112];
                    rd_addr_1_0B = data_buf[111:104];
                    rd_addr_1_0D = data_buf[103:96];
                    rd_addr_2_0D = data_buf[127:120];
                    rd_addr_2_09 = data_buf[119:112];
                    rd_addr_2_0E = data_buf[111:104];
                    rd_addr_2_0B = data_buf[103:96];
                    rd_addr_3_0B = data_buf[127:120];
                    rd_addr_3_0D = data_buf[119:112];
                    rd_addr_3_09 = data_buf[111:104];
                    rd_addr_3_0E = data_buf[103:96];
                end
            DELAY:
                begin
                    rd_addr_0_0E = data_buf[127:120];
                    rd_addr_0_0B = data_buf[119:112];
                    rd_addr_0_0D = data_buf[111:104];
                    rd_addr_0_09 = data_buf[103:96];
                    rd_addr_1_09 = data_buf[127:120];
                    rd_addr_1_0E = data_buf[119:112];
                    rd_addr_1_0B = data_buf[111:104];
                    rd_addr_1_0D = data_buf[103:96];
                    rd_addr_2_0D = data_buf[127:120];
                    rd_addr_2_09 = data_buf[119:112];
                    rd_addr_2_0E = data_buf[111:104];
                    rd_addr_2_0B = data_buf[103:96];
                    rd_addr_3_0B = data_buf[127:120];
                    rd_addr_3_0D = data_buf[119:112];
                    rd_addr_3_09 = data_buf[111:104];
                    rd_addr_3_0E = data_buf[103:96];
                end
            INV_MIX_COLUMS_0:
                begin
                    rd_addr_0_0E = data_buf[95:88];
                    rd_addr_0_0B = data_buf[87:80];
                    rd_addr_0_0D = data_buf[79:72];
                    rd_addr_0_09 = data_buf[71:64];
                    rd_addr_1_09 = data_buf[95:88];
                    rd_addr_1_0E = data_buf[87:80];
                    rd_addr_1_0B = data_buf[79:72];
                    rd_addr_1_0D = data_buf[71:64];
                    rd_addr_2_0D = data_buf[95:88];
                    rd_addr_2_09 = data_buf[87:80];
                    rd_addr_2_0E = data_buf[79:72];
                    rd_addr_2_0B = data_buf[71:64];
                    rd_addr_3_0B = data_buf[95:88];
                    rd_addr_3_0D = data_buf[87:80];
                    rd_addr_3_09 = data_buf[79:72];
                    rd_addr_3_0E = data_buf[71:64];
                end
            INV_MIX_COLUMS_1:
                begin
                    rd_addr_0_0E = data_buf[63:56];
                    rd_addr_0_0B = data_buf[55:48];
                    rd_addr_0_0D = data_buf[47:40];
                    rd_addr_0_09 = data_buf[39:32];
                    rd_addr_1_09 = data_buf[63:56];
                    rd_addr_1_0E = data_buf[55:48];
                    rd_addr_1_0B = data_buf[47:40];
                    rd_addr_1_0D = data_buf[39:32];
                    rd_addr_2_0D = data_buf[63:56];
                    rd_addr_2_09 = data_buf[55:48];
                    rd_addr_2_0E = data_buf[47:40];
                    rd_addr_2_0B = data_buf[39:32];
                    rd_addr_3_0B = data_buf[63:56];
                    rd_addr_3_0D = data_buf[55:48];
                    rd_addr_3_09 = data_buf[47:40];
                    rd_addr_3_0E = data_buf[39:32];
                end
            INV_MIX_COLUMS_2:
                begin
                    rd_addr_0_0E = data_buf[31:24];
                    rd_addr_0_0B = data_buf[23:16];
                    rd_addr_0_0D = data_buf[15:8];
                    rd_addr_0_09 = data_buf[7:0];
                    rd_addr_1_09 = data_buf[31:24];
                    rd_addr_1_0E = data_buf[23:16];
                    rd_addr_1_0B = data_buf[15:8];
                    rd_addr_1_0D = data_buf[7:0];
                    rd_addr_2_0D = data_buf[31:24];
                    rd_addr_2_09 = data_buf[23:16];
                    rd_addr_2_0E = data_buf[15:8];
                    rd_addr_2_0B = data_buf[7:0];
                    rd_addr_3_0B = data_buf[31:24];
                    rd_addr_3_0D = data_buf[23:16];
                    rd_addr_3_09 = data_buf[15:8];
                    rd_addr_3_0E = data_buf[7:0];
                end
            default:
                begin
                    rd_addr_0_0E = 8'd0;
                    rd_addr_0_0B = 8'd0;
                    rd_addr_0_0D = 8'd0;
                    rd_addr_0_09 = 8'd0;
                    rd_addr_1_09 = 8'd0;
                    rd_addr_1_0E = 8'd0;
                    rd_addr_1_0B = 8'd0;
                    rd_addr_1_0D = 8'd0;
                    rd_addr_2_0D = 8'd0;
                    rd_addr_2_09 = 8'd0;
                    rd_addr_2_0E = 8'd0;
                    rd_addr_2_0B = 8'd0;
                    rd_addr_3_0B = 8'd0;
                    rd_addr_3_0D = 8'd0;
                    rd_addr_3_09 = 8'd0;
                    rd_addr_3_0E = 8'd0;
                end
        endcase   
    end

endmodule
