module key_expansion

#(
    parameter START_KEY = 128'h2B7E151628AED2A6ABF7158809CF4F3C
)

(
    input   logic           aclk,
    input   logic           aresetn,

    input   logic   [127:0] s_axis_tdata,
    input   logic           s_axis_tvalid,
    output  logic           s_axis_tready,

    output  logic   [127:0] key_dec [0:10],
    output  logic   [127:0] key_enc [0:10],
    output  logic           key_ready
);

    logic   [127:0] mem_key [0:10];
    logic   [31:0]  W       [0:7];
    logic   [3:0]   round;
    logic   [31:0]  temp_word;

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

    localparam logic [31:0] RCON [0:9] = '{
        32'h01000000, // Round 1
        32'h02000000, // Round 2
        32'h04000000, // Round 3
        32'h08000000, // Round 4
        32'h10000000, // Round 5
        32'h20000000, // Round 6
        32'h40000000, // Round 7
        32'h80000000, // Round 8
        32'h1B000000, // Round 9
        32'h36000000  // Round 10
    };

    // FSM states
    typedef enum logic [3:0]
    {  
        IDLE,
        LOAD_KEY,
        CALC_KEY_0,
        CALC_KEY_1,
        CALC_KEY_2,
        CALC_KEY_3,
        CALC_KEY_4,
        CALC_KEY_5,
        CALC_KEY_6,
        CALC_KEY_7,
        WAIT_KEY
    } state_type;

    state_type state;

    always_ff @(posedge aclk) begin
        if (!aresetn) begin
            state <= IDLE;
            s_axis_tready <= 1'd0;
            round <= 4'd0;
        end else begin
            case (state)
                IDLE:
                    begin
                        state <= LOAD_KEY;
                        mem_key[round] <= START_KEY;
                    end
                LOAD_KEY:
                    begin
                        state <= CALC_KEY_0;
                        W[0] <= mem_key[round][127:96];
                        W[1] <= mem_key[round][95:64];
                        W[2] <= mem_key[round][63:32];
                        W[3] <= mem_key[round][31:0];
                        round <= round + 1'd1;
                    end
                CALC_KEY_0:
                    begin
                        state <= CALC_KEY_1;
                        temp_word <= {W[3][23:0], W[3][31:24]};
                    end
                CALC_KEY_1:
                    begin
                        state <= CALC_KEY_2;
                        for (int i = 0; i < 4; i++) begin
                            temp_word[i*8 +: 8] <= SBOX[temp_word[i*8 +: 8]];
                        end
                    end
                CALC_KEY_2:
                    begin
                        state <= CALC_KEY_3;
                        temp_word <= temp_word ^ RCON[round-1];
                    end
                CALC_KEY_3:
                    begin
                        state <= CALC_KEY_4;
                        W[4] <= W[0] ^ temp_word;
                    end
                CALC_KEY_4:
                    begin
                        state <= CALC_KEY_5;
                        W[5] <= W[1] ^ W[4];
                    end
                CALC_KEY_5:
                    begin
                        state <= CALC_KEY_6;
                        W[6] <= W[2] ^ W[5];
                    end
                CALC_KEY_6:
                    begin
                        state <= CALC_KEY_7;
                        W[7] <= W[3] ^ W[6];
                    end
                CALC_KEY_7:
                    begin
                        if (round < 4'd10) begin
                            state <= LOAD_KEY;
                        end else begin
                            state <= WAIT_KEY;
                            round <= 4'd0;
                        end

                        mem_key[round] <= {W[4], W[5], W[6], W[7]};
                    end
                WAIT_KEY:
                    begin
                        s_axis_tready <= 1'd1;

                        if (s_axis_tvalid && s_axis_tready) begin
                            state <= LOAD_KEY;
                            mem_key[round] <= s_axis_tdata;
                            s_axis_tready <= 1'd0;
                        end
                    end
                default:
                    begin
                        state <= IDLE;
                        s_axis_tready <= 1'd0;
                        round <= 4'd0;
                    end
            endcase
        end
    end

    assign key_ready = s_axis_tready;

    assign key_dec[10] = mem_key[0];
    assign key_dec[9]  = mem_key[1];
    assign key_dec[8]  = mem_key[2];
    assign key_dec[7]  = mem_key[3];
    assign key_dec[6]  = mem_key[4];
    assign key_dec[5]  = mem_key[5];
    assign key_dec[4]  = mem_key[6];
    assign key_dec[3]  = mem_key[7];
    assign key_dec[2]  = mem_key[8];
    assign key_dec[1]  = mem_key[9];
    assign key_dec[0]  = mem_key[10];

    assign key_enc[0]  = mem_key[0];
    assign key_enc[1]  = mem_key[1];
    assign key_enc[2]  = mem_key[2];
    assign key_enc[3]  = mem_key[3];
    assign key_enc[4]  = mem_key[4];
    assign key_enc[5]  = mem_key[5];
    assign key_enc[6]  = mem_key[6];
    assign key_enc[7]  = mem_key[7];
    assign key_enc[8]  = mem_key[8];
    assign key_enc[9]  = mem_key[9];
    assign key_enc[10] = mem_key[10];

endmodule