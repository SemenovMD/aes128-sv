module stage_enc_add_round_key

(
    input   logic           aclk,
    input   logic           aresetn,
    input   logic           en,

    input   logic   [127:0] key,

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
                data_out <= data_in ^ key;
                valid_out <= valid_in;
            end
        end
    end

endmodule