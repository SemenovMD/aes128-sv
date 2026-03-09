module stage_enc_shift_rows

(
    input   logic           aclk,
    input   logic           aresetn,
    input   logic           en,

    input   logic   [127:0] data_in,
    input   logic           valid_in,

    output  logic   [127:0] data_out,
    output  logic           valid_out
);

    always_ff @(posedge aclk) begin
        if (!aresetn) begin
            valid_out <= 1'd0;
        end else begin
            if (en) begin
                data_out[127:96] <= {data_in[127:120], data_in[87:80],   data_in[47:40],   data_in[7:0]};
                data_out[95:64]  <= {data_in[95:88],   data_in[55:48],   data_in[15:8],    data_in[103:96]};
                data_out[63:32]  <= {data_in[63:56],   data_in[23:16],   data_in[111:104], data_in[71:64]};
                data_out[31:0]   <= {data_in[31:24],   data_in[119:112], data_in[79:72],   data_in[39:32]};
                valid_out        <= valid_in;
            end
        end
    end

endmodule