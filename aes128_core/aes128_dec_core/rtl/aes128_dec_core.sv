module aes128_dec_core

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

    // Mult GF(2^8) InvMixColumns
    localparam logic [7:0] MULT_0E [0:255] = '{
        //  0      1      2      3      4      5      6      7      8      9      A      B      C      D      E      F
        8'h00, 8'h0E, 8'h1C, 8'h12, 8'h38, 8'h36, 8'h24, 8'h2A, 8'h70, 8'h7E, 8'h6C, 8'h62, 8'h48, 8'h46, 8'h54, 8'h5A, // 0
        8'hE0, 8'hEE, 8'hFC, 8'hF2, 8'hD8, 8'hD6, 8'hC4, 8'hCA, 8'h90, 8'h9E, 8'h8C, 8'h82, 8'hA8, 8'hA6, 8'hB4, 8'hBA, // 1
        8'hDB, 8'hD5, 8'hC7, 8'hC9, 8'hE3, 8'hED, 8'hFF, 8'hF1, 8'hAB, 8'hA5, 8'hB7, 8'hB9, 8'h93, 8'h9D, 8'h8F, 8'h81, // 2
        8'h3B, 8'h35, 8'h27, 8'h29, 8'h03, 8'h0D, 8'h1F, 8'h11, 8'h4B, 8'h45, 8'h57, 8'h59, 8'h73, 8'h7D, 8'h6F, 8'h61, // 3
        8'hAD, 8'hA3, 8'hB1, 8'hBF, 8'h95, 8'h9B, 8'h89, 8'h87, 8'hDD, 8'hD3, 8'hC1, 8'hCF, 8'hE5, 8'hEB, 8'hF9, 8'hF7, // 4
        8'h4D, 8'h43, 8'h51, 8'h5F, 8'h75, 8'h7B, 8'h69, 8'h67, 8'h3D, 8'h33, 8'h21, 8'h2F, 8'h05, 8'h0B, 8'h19, 8'h17, // 5
        8'h76, 8'h78, 8'h6A, 8'h64, 8'h4E, 8'h40, 8'h52, 8'h5C, 8'h06, 8'h08, 8'h1A, 8'h14, 8'h3E, 8'h30, 8'h22, 8'h2C, // 6
        8'h96, 8'h98, 8'h8A, 8'h84, 8'hAE, 8'hA0, 8'hB2, 8'hBC, 8'hE6, 8'hE8, 8'hFA, 8'hF4, 8'hDE, 8'hD0, 8'hC2, 8'hCC, // 7
        8'h41, 8'h4F, 8'h5D, 8'h53, 8'h79, 8'h77, 8'h65, 8'h6B, 8'h31, 8'h3F, 8'h2D, 8'h23, 8'h09, 8'h07, 8'h15, 8'h1B, // 8
        8'hA1, 8'hAF, 8'hBD, 8'hB3, 8'h99, 8'h97, 8'h85, 8'h8B, 8'hD1, 8'hDF, 8'hCD, 8'hC3, 8'hE9, 8'hE7, 8'hF5, 8'hFB, // 9
        8'h9A, 8'h94, 8'h86, 8'h88, 8'hA2, 8'hAC, 8'hBE, 8'hB0, 8'hEA, 8'hE4, 8'hF6, 8'hF8, 8'hD2, 8'hDC, 8'hCE, 8'hC0, // A
        8'h7A, 8'h74, 8'h66, 8'h68, 8'h42, 8'h4C, 8'h5E, 8'h50, 8'h0A, 8'h04, 8'h16, 8'h18, 8'h32, 8'h3C, 8'h2E, 8'h20, // B
        8'hEC, 8'hE2, 8'hF0, 8'hFE, 8'hD4, 8'hDA, 8'hC8, 8'hC6, 8'h9C, 8'h92, 8'h80, 8'h8E, 8'hA4, 8'hAA, 8'hB8, 8'hB6, // C
        8'h0C, 8'h02, 8'h10, 8'h1E, 8'h34, 8'h3A, 8'h28, 8'h26, 8'h7C, 8'h72, 8'h60, 8'h6E, 8'h44, 8'h4A, 8'h58, 8'h56, // D
        8'h37, 8'h39, 8'h2B, 8'h25, 8'h0F, 8'h01, 8'h13, 8'h1D, 8'h47, 8'h49, 8'h5B, 8'h55, 8'h7F, 8'h71, 8'h63, 8'h6D, // E
        8'hD7, 8'hD9, 8'hCB, 8'hC5, 8'hEF, 8'hE1, 8'hF3, 8'hFD, 8'hA7, 8'hA9, 8'hBB, 8'hB5, 8'h9F, 8'h91, 8'h83, 8'h8D  // F
    };

    localparam logic [7:0] MULT_0B [0:255] = '{
        //  0      1      2      3      4      5      6      7      8      9      A      B      C      D      E      F
        8'h00, 8'h0B, 8'h16, 8'h1D, 8'h2C, 8'h27, 8'h3A, 8'h31, 8'h58, 8'h53, 8'h4E, 8'h45, 8'h74, 8'h7F, 8'h62, 8'h69, // 0
        8'hB0, 8'hBB, 8'hA6, 8'hAD, 8'h9C, 8'h97, 8'h8A, 8'h81, 8'hE8, 8'hE3, 8'hFE, 8'hF5, 8'hC4, 8'hCF, 8'hD2, 8'hD9, // 1
        8'h7B, 8'h70, 8'h6D, 8'h66, 8'h57, 8'h5C, 8'h41, 8'h4A, 8'h23, 8'h28, 8'h35, 8'h3E, 8'h0F, 8'h04, 8'h19, 8'h12, // 2
        8'hCB, 8'hC0, 8'hDD, 8'hD6, 8'hE7, 8'hEC, 8'hF1, 8'hFA, 8'h93, 8'h98, 8'h85, 8'h8E, 8'hBF, 8'hB4, 8'hA9, 8'hA2, // 3
        8'hF6, 8'hFD, 8'hE0, 8'hEB, 8'hDA, 8'hD1, 8'hCC, 8'hC7, 8'hAE, 8'hA5, 8'hB8, 8'hB3, 8'h82, 8'h89, 8'h94, 8'h9F, // 4
        8'h46, 8'h4D, 8'h50, 8'h5B, 8'h6A, 8'h61, 8'h7C, 8'h77, 8'h1E, 8'h15, 8'h08, 8'h03, 8'h32, 8'h39, 8'h24, 8'h2F, // 5
        8'h8D, 8'h86, 8'h9B, 8'h90, 8'hA1, 8'hAA, 8'hB7, 8'hBC, 8'hD5, 8'hDE, 8'hC3, 8'hC8, 8'hF9, 8'hF2, 8'hEF, 8'hE4, // 6
        8'h3D, 8'h36, 8'h2B, 8'h20, 8'h11, 8'h1A, 8'h07, 8'h0C, 8'h65, 8'h6E, 8'h73, 8'h78, 8'h49, 8'h42, 8'h5F, 8'h54, // 7
        8'hF7, 8'hFC, 8'hE1, 8'hEA, 8'hDB, 8'hD0, 8'hCD, 8'hC6, 8'hAF, 8'hA4, 8'hB9, 8'hB2, 8'h83, 8'h88, 8'h95, 8'h9E, // 8
        8'h47, 8'h4C, 8'h51, 8'h5A, 8'h6B, 8'h60, 8'h7D, 8'h76, 8'h1F, 8'h14, 8'h09, 8'h02, 8'h33, 8'h38, 8'h25, 8'h2E, // 9
        8'h8C, 8'h87, 8'h9A, 8'h91, 8'hA0, 8'hAB, 8'hB6, 8'hBD, 8'hD4, 8'hDF, 8'hC2, 8'hC9, 8'hF8, 8'hF3, 8'hEE, 8'hE5, // A
        8'h3C, 8'h37, 8'h2A, 8'h21, 8'h10, 8'h1B, 8'h06, 8'h0D, 8'h64, 8'h6F, 8'h72, 8'h79, 8'h48, 8'h43, 8'h5E, 8'h55, // B
        8'h01, 8'h0A, 8'h17, 8'h1C, 8'h2D, 8'h26, 8'h3B, 8'h30, 8'h59, 8'h52, 8'h4F, 8'h44, 8'h75, 8'h7E, 8'h63, 8'h68, // C
        8'hB1, 8'hBA, 8'hA7, 8'hAC, 8'h9D, 8'h96, 8'h8B, 8'h80, 8'hE9, 8'hE2, 8'hFF, 8'hF4, 8'hC5, 8'hCE, 8'hD3, 8'hD8, // D
        8'h7A, 8'h71, 8'h6C, 8'h67, 8'h56, 8'h5D, 8'h40, 8'h4B, 8'h22, 8'h29, 8'h34, 8'h3F, 8'h0E, 8'h05, 8'h18, 8'h13, // E
        8'hCA, 8'hC1, 8'hDC, 8'hD7, 8'hE6, 8'hED, 8'hF0, 8'hFB, 8'h92, 8'h99, 8'h84, 8'h8F, 8'hBE, 8'hB5, 8'hA8, 8'hA3  // F
    };

    localparam logic [7:0] MULT_0D [0:255] = '{
        //  0      1      2      3      4      5      6      7      8      9      A      B      C      D      E      F
        8'h00, 8'h0D, 8'h1A, 8'h17, 8'h34, 8'h39, 8'h2E, 8'h23, 8'h68, 8'h65, 8'h72, 8'h7F, 8'h5C, 8'h51, 8'h46, 8'h4B, // 0
        8'hD0, 8'hDD, 8'hCA, 8'hC7, 8'hE4, 8'hE9, 8'hFE, 8'hF3, 8'hB8, 8'hB5, 8'hA2, 8'hAF, 8'h8C, 8'h81, 8'h96, 8'h9B, // 1
        8'hBB, 8'hB6, 8'hA1, 8'hAC, 8'h8F, 8'h82, 8'h95, 8'h98, 8'hD3, 8'hDE, 8'hC9, 8'hC4, 8'hE7, 8'hEA, 8'hFD, 8'hF0, // 2
        8'h6B, 8'h66, 8'h71, 8'h7C, 8'h5F, 8'h52, 8'h45, 8'h48, 8'h03, 8'h0E, 8'h19, 8'h14, 8'h37, 8'h3A, 8'h2D, 8'h20, // 3
        8'h6D, 8'h60, 8'h77, 8'h7A, 8'h59, 8'h54, 8'h43, 8'h4E, 8'h05, 8'h08, 8'h1F, 8'h12, 8'h31, 8'h3C, 8'h2B, 8'h26, // 4
        8'hBD, 8'hB0, 8'hA7, 8'hAA, 8'h89, 8'h84, 8'h93, 8'h9E, 8'hD5, 8'hD8, 8'hCF, 8'hC2, 8'hE1, 8'hEC, 8'hFB, 8'hF6, // 5
        8'hD6, 8'hDB, 8'hCC, 8'hC1, 8'hE2, 8'hEF, 8'hF8, 8'hF5, 8'hBE, 8'hB3, 8'hA4, 8'hA9, 8'h8A, 8'h87, 8'h90, 8'h9D, // 6
        8'h06, 8'h0B, 8'h1C, 8'h11, 8'h32, 8'h3F, 8'h28, 8'h25, 8'h6E, 8'h63, 8'h74, 8'h79, 8'h5A, 8'h57, 8'h40, 8'h4D, // 7
        8'hDA, 8'hD7, 8'hC0, 8'hCD, 8'hEE, 8'hE3, 8'hF4, 8'hF9, 8'hB2, 8'hBF, 8'hA8, 8'hA5, 8'h86, 8'h8B, 8'h9C, 8'h91, // 8
        8'h0A, 8'h07, 8'h10, 8'h1D, 8'h3E, 8'h33, 8'h24, 8'h29, 8'h62, 8'h6F, 8'h78, 8'h75, 8'h56, 8'h5B, 8'h4C, 8'h41, // 9
        8'h61, 8'h6C, 8'h7B, 8'h76, 8'h55, 8'h58, 8'h4F, 8'h42, 8'h09, 8'h04, 8'h13, 8'h1E, 8'h3D, 8'h30, 8'h27, 8'h2A, // A
        8'hB1, 8'hBC, 8'hAB, 8'hA6, 8'h85, 8'h88, 8'h9F, 8'h92, 8'hD9, 8'hD4, 8'hC3, 8'hCE, 8'hED, 8'hE0, 8'hF7, 8'hFA, // B
        8'hB7, 8'hBA, 8'hAD, 8'hA0, 8'h83, 8'h8E, 8'h99, 8'h94, 8'hDF, 8'hD2, 8'hC5, 8'hC8, 8'hEB, 8'hE6, 8'hF1, 8'hFC, // C
        8'h67, 8'h6A, 8'h7D, 8'h70, 8'h53, 8'h5E, 8'h49, 8'h44, 8'h0F, 8'h02, 8'h15, 8'h18, 8'h3B, 8'h36, 8'h21, 8'h2C, // D
        8'h0C, 8'h01, 8'h16, 8'h1B, 8'h38, 8'h35, 8'h22, 8'h2F, 8'h64, 8'h69, 8'h7E, 8'h73, 8'h50, 8'h5D, 8'h4A, 8'h47, // E
        8'hDC, 8'hD1, 8'hC6, 8'hCB, 8'hE8, 8'hE5, 8'hF2, 8'hFF, 8'hB4, 8'hB9, 8'hAE, 8'hA3, 8'h80, 8'h8D, 8'h9A, 8'h97  // F
    };

    localparam logic [7:0] MULT_09 [0:255] = '{
        //  0      1      2      3      4      5      6      7      8      9      A      B      C      D      E      F
        8'h00, 8'h09, 8'h12, 8'h1B, 8'h24, 8'h2D, 8'h36, 8'h3F, 8'h48, 8'h41, 8'h5A, 8'h53, 8'h6C, 8'h65, 8'h7E, 8'h77, // 0
        8'h90, 8'h99, 8'h82, 8'h8B, 8'hB4, 8'hBD, 8'hA6, 8'hAF, 8'hD8, 8'hD1, 8'hCA, 8'hC3, 8'hFC, 8'hF5, 8'hEE, 8'hE7, // 1
        8'h3B, 8'h32, 8'h29, 8'h20, 8'h1F, 8'h16, 8'h0D, 8'h04, 8'h73, 8'h7A, 8'h61, 8'h68, 8'h57, 8'h5E, 8'h45, 8'h4C, // 2
        8'hAB, 8'hA2, 8'hB9, 8'hB0, 8'h8F, 8'h86, 8'h9D, 8'h94, 8'hE3, 8'hEA, 8'hF1, 8'hF8, 8'hC7, 8'hCE, 8'hD5, 8'hDC, // 3
        8'h76, 8'h7F, 8'h64, 8'h6D, 8'h52, 8'h5B, 8'h40, 8'h49, 8'h3E, 8'h37, 8'h2C, 8'h25, 8'h1A, 8'h13, 8'h08, 8'h01, // 4
        8'hE6, 8'hEF, 8'hF4, 8'hFD, 8'hC2, 8'hCB, 8'hD0, 8'hD9, 8'hAE, 8'hA7, 8'hBC, 8'hB5, 8'h8A, 8'h83, 8'h98, 8'h91, // 5
        8'h4D, 8'h44, 8'h5F, 8'h56, 8'h69, 8'h60, 8'h7B, 8'h72, 8'h05, 8'h0C, 8'h17, 8'h1E, 8'h21, 8'h28, 8'h33, 8'h3A, // 6
        8'hDD, 8'hD4, 8'hCF, 8'hC6, 8'hF9, 8'hF0, 8'hEB, 8'hE2, 8'h95, 8'h9C, 8'h87, 8'h8E, 8'hB1, 8'hB8, 8'hA3, 8'hAA, // 7
        8'hEC, 8'hE5, 8'hFE, 8'hF7, 8'hC8, 8'hC1, 8'hDA, 8'hD3, 8'hA4, 8'hAD, 8'hB6, 8'hBF, 8'h80, 8'h89, 8'h92, 8'h9B, // 8
        8'h7C, 8'h75, 8'h6E, 8'h67, 8'h58, 8'h51, 8'h4A, 8'h43, 8'h34, 8'h3D, 8'h26, 8'h2F, 8'h10, 8'h19, 8'h02, 8'h0B, // 9
        8'hD7, 8'hDE, 8'hC5, 8'hCC, 8'hF3, 8'hFA, 8'hE1, 8'hE8, 8'h9F, 8'h96, 8'h8D, 8'h84, 8'hBB, 8'hB2, 8'hA9, 8'hA0, // A
        8'h47, 8'h4E, 8'h55, 8'h5C, 8'h63, 8'h6A, 8'h71, 8'h78, 8'h0F, 8'h06, 8'h1D, 8'h14, 8'h2B, 8'h22, 8'h39, 8'h30, // B
        8'h9A, 8'h93, 8'h88, 8'h81, 8'hBE, 8'hB7, 8'hAC, 8'hA5, 8'hD2, 8'hDB, 8'hC0, 8'hC9, 8'hF6, 8'hFF, 8'hE4, 8'hED, // C
        8'h0A, 8'h03, 8'h18, 8'h11, 8'h2E, 8'h27, 8'h3C, 8'h35, 8'h42, 8'h4B, 8'h50, 8'h59, 8'h66, 8'h6F, 8'h74, 8'h7D, // D
        8'hA1, 8'hA8, 8'hB3, 8'hBA, 8'h85, 8'h8C, 8'h97, 8'h9E, 8'hE9, 8'hE0, 8'hFB, 8'hF2, 8'hCD, 8'hC4, 8'hDF, 8'hD6, // E
        8'h31, 8'h38, 8'h23, 8'h2A, 8'h15, 8'h1C, 8'h07, 8'h0E, 8'h79, 8'h70, 8'h6B, 8'h62, 8'h5D, 8'h54, 8'h4F, 8'h46  // F
    };

    logic   [127:0] data_buf;

    logic   [3:0]   count;

    logic   [7:0]   rd_addr_0_0E,  rd_addr_0_0B,  rd_addr_0_0D,  rd_addr_0_09;
    logic   [7:0]   rd_addr_1_0E,  rd_addr_1_0B,  rd_addr_1_0D,  rd_addr_1_09;
    logic   [7:0]   rd_addr_2_0E,  rd_addr_2_0B,  rd_addr_2_0D,  rd_addr_2_09;
    logic   [7:0]   rd_addr_3_0E,  rd_addr_3_0B,  rd_addr_3_0D,  rd_addr_3_09;
    logic   [7:0]   rd_addr_4_0E,  rd_addr_4_0B,  rd_addr_4_0D,  rd_addr_4_09;
    logic   [7:0]   rd_addr_5_0E,  rd_addr_5_0B,  rd_addr_5_0D,  rd_addr_5_09;
    logic   [7:0]   rd_addr_6_0E,  rd_addr_6_0B,  rd_addr_6_0D,  rd_addr_6_09;
    logic   [7:0]   rd_addr_7_0E,  rd_addr_7_0B,  rd_addr_7_0D,  rd_addr_7_09;
    logic   [7:0]   rd_addr_8_0E,  rd_addr_8_0B,  rd_addr_8_0D,  rd_addr_8_09;
    logic   [7:0]   rd_addr_9_0E,  rd_addr_9_0B,  rd_addr_9_0D,  rd_addr_9_09;
    logic   [7:0]   rd_addr_10_0E, rd_addr_10_0B, rd_addr_10_0D, rd_addr_10_09;
    logic   [7:0]   rd_addr_11_0E, rd_addr_11_0B, rd_addr_11_0D, rd_addr_11_09;
    logic   [7:0]   rd_addr_12_0E, rd_addr_12_0B, rd_addr_12_0D, rd_addr_12_09;
    logic   [7:0]   rd_addr_13_0E, rd_addr_13_0B, rd_addr_13_0D, rd_addr_13_09;
    logic   [7:0]   rd_addr_14_0E, rd_addr_14_0B, rd_addr_14_0D, rd_addr_14_09;
    logic   [7:0]   rd_addr_15_0E, rd_addr_15_0B, rd_addr_15_0D, rd_addr_15_09;
    
    logic   [7:0]   rd_data_0_0E,  rd_data_0_0B,  rd_data_0_0D,  rd_data_0_09;
    logic   [7:0]   rd_data_1_0E,  rd_data_1_0B,  rd_data_1_0D,  rd_data_1_09;
    logic   [7:0]   rd_data_2_0E,  rd_data_2_0B,  rd_data_2_0D,  rd_data_2_09;
    logic   [7:0]   rd_data_3_0E,  rd_data_3_0B,  rd_data_3_0D,  rd_data_3_09;
    logic   [7:0]   rd_data_4_0E,  rd_data_4_0B,  rd_data_4_0D,  rd_data_4_09;
    logic   [7:0]   rd_data_5_0E,  rd_data_5_0B,  rd_data_5_0D,  rd_data_5_09;
    logic   [7:0]   rd_data_6_0E,  rd_data_6_0B,  rd_data_6_0D,  rd_data_6_09;
    logic   [7:0]   rd_data_7_0E,  rd_data_7_0B,  rd_data_7_0D,  rd_data_7_09;
    logic   [7:0]   rd_data_8_0E,  rd_data_8_0B,  rd_data_8_0D,  rd_data_8_09;
    logic   [7:0]   rd_data_9_0E,  rd_data_9_0B,  rd_data_9_0D,  rd_data_9_09;
    logic   [7:0]   rd_data_10_0E, rd_data_10_0B, rd_data_10_0D, rd_data_10_09;
    logic   [7:0]   rd_data_11_0E, rd_data_11_0B, rd_data_11_0D, rd_data_11_09;
    logic   [7:0]   rd_data_12_0E, rd_data_12_0B, rd_data_12_0D, rd_data_12_09;
    logic   [7:0]   rd_data_13_0E, rd_data_13_0B, rd_data_13_0D, rd_data_13_09;
    logic   [7:0]   rd_data_14_0E, rd_data_14_0B, rd_data_14_0D, rd_data_14_09;
    logic   [7:0]   rd_data_15_0E, rd_data_15_0B, rd_data_15_0D, rd_data_15_09;

    //////////////////////////////////////////////////////////////////////////////////////////
    // FSM
    //////////////////////////////////////////////////////////////////////////////////////////
    typedef enum logic [2:0] 
    {
        START,
        HAND_S_AXIS,
        ADD_ROUND_INV_KEY_0,
        INV_SHIFT_ROWS,
        INV_SUB_BYTES,
        ADD_ROUND_INV_KEY_1,
        INV_MIX_COLUMNS,
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
                            state <= ADD_ROUND_INV_KEY_0;
                            data_buf <= s_axis_tdata;
                            s_axis_tready <= 1'd0;
                        end

                        m_axis_tvalid <= 1'd0;
                    end
                ADD_ROUND_INV_KEY_0:
                    begin
                        state <= INV_SHIFT_ROWS;
                        data_buf <= data_buf ^ key[count];
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
                        state <= ADD_ROUND_INV_KEY_1;

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
                ADD_ROUND_INV_KEY_1:
                    begin
                        if (count != 4'd10) begin
                            count <= count + 1'd1;
                            state <= INV_MIX_COLUMNS;
                        end else begin
                            count <= 4'd0;
                            state <= HAND_M_AXIS;
                        end

                        data_buf <= data_buf ^ key[count];
                    end
                INV_MIX_COLUMNS:
                    begin
                        state <= INV_SHIFT_ROWS;
                        data_buf[127:120] <= (MULT_0E[rd_addr_0_0E]  ^ MULT_0B[rd_addr_0_0B])  ^ (MULT_0D[rd_addr_0_0D]  ^ MULT_09[rd_addr_0_09]);
                        data_buf[119:112] <= (MULT_0E[rd_addr_1_0E]  ^ MULT_0B[rd_addr_1_0B])  ^ (MULT_0D[rd_addr_1_0D]  ^ MULT_09[rd_addr_1_09]);
                        data_buf[111:104] <= (MULT_0E[rd_addr_2_0E]  ^ MULT_0B[rd_addr_2_0B])  ^ (MULT_0D[rd_addr_2_0D]  ^ MULT_09[rd_addr_2_09]);
                        data_buf[103:96]  <= (MULT_0E[rd_addr_3_0E]  ^ MULT_0B[rd_addr_3_0B])  ^ (MULT_0D[rd_addr_3_0D]  ^ MULT_09[rd_addr_3_09]);
                        data_buf[95:88]   <= (MULT_0E[rd_addr_4_0E]  ^ MULT_0B[rd_addr_4_0B])  ^ (MULT_0D[rd_addr_4_0D]  ^ MULT_09[rd_addr_4_09]);
                        data_buf[87:80]   <= (MULT_0E[rd_addr_5_0E]  ^ MULT_0B[rd_addr_5_0B])  ^ (MULT_0D[rd_addr_5_0D]  ^ MULT_09[rd_addr_5_09]);
                        data_buf[79:72]   <= (MULT_0E[rd_addr_6_0E]  ^ MULT_0B[rd_addr_6_0B])  ^ (MULT_0D[rd_addr_6_0D]  ^ MULT_09[rd_addr_6_09]);
                        data_buf[71:64]   <= (MULT_0E[rd_addr_7_0E]  ^ MULT_0B[rd_addr_7_0B])  ^ (MULT_0D[rd_addr_7_0D]  ^ MULT_09[rd_addr_7_09]);
                        data_buf[63:56]   <= (MULT_0E[rd_addr_8_0E]  ^ MULT_0B[rd_addr_8_0B])  ^ (MULT_0D[rd_addr_8_0D]  ^ MULT_09[rd_addr_8_09]);
                        data_buf[55:48]   <= (MULT_0E[rd_addr_9_0E]  ^ MULT_0B[rd_addr_9_0B])  ^ (MULT_0D[rd_addr_9_0D]  ^ MULT_09[rd_addr_9_09]);
                        data_buf[47:40]   <= (MULT_0E[rd_addr_10_0E] ^ MULT_0B[rd_addr_10_0B]) ^ (MULT_0D[rd_addr_10_0D] ^ MULT_09[rd_addr_10_09]);
                        data_buf[39:32]   <= (MULT_0E[rd_addr_11_0E] ^ MULT_0B[rd_addr_11_0B]) ^ (MULT_0D[rd_addr_11_0D] ^ MULT_09[rd_addr_11_09]);
                        data_buf[31:24]   <= (MULT_0E[rd_addr_12_0E] ^ MULT_0B[rd_addr_12_0B]) ^ (MULT_0D[rd_addr_12_0D] ^ MULT_09[rd_addr_12_09]);
                        data_buf[23:16]   <= (MULT_0E[rd_addr_13_0E] ^ MULT_0B[rd_addr_13_0B]) ^ (MULT_0D[rd_addr_13_0D] ^ MULT_09[rd_addr_13_09]);
                        data_buf[15:8]    <= (MULT_0E[rd_addr_14_0E] ^ MULT_0B[rd_addr_14_0B]) ^ (MULT_0D[rd_addr_14_0D] ^ MULT_09[rd_addr_14_09]);
                        data_buf[7:0]     <= (MULT_0E[rd_addr_15_0E] ^ MULT_0B[rd_addr_15_0B]) ^ (MULT_0D[rd_addr_15_0D] ^ MULT_09[rd_addr_15_09]);
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
        rd_addr_0_0E  = data_buf[127:120];
        rd_addr_0_0B  = data_buf[119:112];
        rd_addr_0_0D  = data_buf[111:104];
        rd_addr_0_09  = data_buf[103:96];
        rd_addr_1_09  = data_buf[127:120];
        rd_addr_1_0E  = data_buf[119:112];
        rd_addr_1_0B  = data_buf[111:104];
        rd_addr_1_0D  = data_buf[103:96];
        rd_addr_2_0D  = data_buf[127:120];
        rd_addr_2_09  = data_buf[119:112];
        rd_addr_2_0E  = data_buf[111:104];
        rd_addr_2_0B  = data_buf[103:96];
        rd_addr_3_0B  = data_buf[127:120];
        rd_addr_3_0D  = data_buf[119:112];
        rd_addr_3_09  = data_buf[111:104];
        rd_addr_3_0E  = data_buf[103:96];

        rd_addr_4_0E  = data_buf[95:88];
        rd_addr_4_0B  = data_buf[87:80];
        rd_addr_4_0D  = data_buf[79:72];
        rd_addr_4_09  = data_buf[71:64];
        rd_addr_5_09  = data_buf[95:88];
        rd_addr_5_0E  = data_buf[87:80];
        rd_addr_5_0B  = data_buf[79:72];
        rd_addr_5_0D  = data_buf[71:64];
        rd_addr_6_0D  = data_buf[95:88];
        rd_addr_6_09  = data_buf[87:80];
        rd_addr_6_0E  = data_buf[79:72];
        rd_addr_6_0B  = data_buf[71:64];
        rd_addr_7_0B  = data_buf[95:88];
        rd_addr_7_0D  = data_buf[87:80];
        rd_addr_7_09  = data_buf[79:72];
        rd_addr_7_0E  = data_buf[71:64];

        rd_addr_8_0E  = data_buf[63:56];
        rd_addr_8_0B  = data_buf[55:48];
        rd_addr_8_0D  = data_buf[47:40];
        rd_addr_8_09  = data_buf[39:32];
        rd_addr_9_09  = data_buf[63:56];
        rd_addr_9_0E  = data_buf[55:48];
        rd_addr_9_0B  = data_buf[47:40];
        rd_addr_9_0D  = data_buf[39:32];
        rd_addr_10_0D = data_buf[63:56];
        rd_addr_10_09 = data_buf[55:48];
        rd_addr_10_0E = data_buf[47:40];
        rd_addr_10_0B = data_buf[39:32];
        rd_addr_11_0B = data_buf[63:56];
        rd_addr_11_0D = data_buf[55:48];
        rd_addr_11_09 = data_buf[47:40];
        rd_addr_11_0E = data_buf[39:32];

        rd_addr_12_0E = data_buf[31:24];
        rd_addr_12_0B = data_buf[23:16];
        rd_addr_12_0D = data_buf[15:8];
        rd_addr_12_09 = data_buf[7:0];
        rd_addr_13_09 = data_buf[31:24];
        rd_addr_13_0E = data_buf[23:16];
        rd_addr_13_0B = data_buf[15:8];
        rd_addr_13_0D = data_buf[7:0];
        rd_addr_14_0D = data_buf[31:24];
        rd_addr_14_09 = data_buf[23:16];
        rd_addr_14_0E = data_buf[15:8];
        rd_addr_14_0B = data_buf[7:0];
        rd_addr_15_0B = data_buf[31:24];
        rd_addr_15_0D = data_buf[23:16];
        rd_addr_15_09 = data_buf[15:8];
        rd_addr_15_0E = data_buf[7:0];
    end

endmodule