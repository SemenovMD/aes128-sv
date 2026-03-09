module round_stage_enc_final

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

    logic   [127:0] data_shift_rows;
    logic           valid_shift_rows;

    logic   [127:0] data_sub_bytes;
    logic           valid_sub_bytes;

    logic   [127:0] data_add_round_key;
    logic           valid_add_round_key;

    stage_enc_shift_rows stage_enc_shift_rows_inst
    (
        .aclk      (aclk),
        .aresetn   (aresetn),
        .en        (en),
        .data_in   (data_in),
        .valid_in  (valid_in),
        .data_out  (data_shift_rows),
        .valid_out (valid_shift_rows)
    );

    stage_enc_sub_bytes stage_enc_sub_bytes_inst
    (
        .aclk      (aclk),
        .aresetn   (aresetn),
        .en        (en),
        .data_in   (data_shift_rows),
        .valid_in  (valid_shift_rows),
        .data_out  (data_sub_bytes),
        .valid_out (valid_sub_bytes)
    );

    stage_enc_add_round_key stage_enc_add_round_key_inst
    (
        .aclk      (aclk),
        .aresetn   (aresetn),
        .en        (en),
        .key       (key),
        .data_in   (data_sub_bytes),
        .valid_in  (valid_sub_bytes),
        .data_out  (data_add_round_key),
        .valid_out (valid_add_round_key)
    );

    assign data_out  = data_add_round_key;
    assign valid_out = valid_add_round_key;

endmodule