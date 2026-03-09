module aes128_dec_pp 

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

    logic   [127:0] data_stage  [0:11];
    logic   [11:0]  valid_stage;

    logic           full;

    stage_dec_hand_s_axis stage_dec_hand_s_axis_inst
    (
        .aclk(aclk),
        .aresetn(aresetn),
        .s_axis_tdata(s_axis_tdata),
        .s_axis_tvalid(s_axis_tvalid),
        .s_axis_tready(s_axis_tready),
        .data_out(data_stage[0]),
        .data_valid(valid_stage[0]),
        .full(full)
    );

    stage_dec_add_round_key stage_dec_add_round_key_inst
    (
        .aclk(aclk),
        .aresetn(aresetn),
        .en(s_axis_tready),
        .key(key[0]),
        .data_in(data_stage[0]),
        .valid_in(valid_stage[0]),
        .data_out(data_stage[1]),
        .valid_out(valid_stage[1])
    );

    genvar i;

    generate
        for (i = 1; i < 10; i++) begin : gen_round_stage_dec
            round_stage_dec round_stage_dec_inst
            (
                .aclk(aclk),
                .aresetn(aresetn),
                .en(s_axis_tready),
                .key(key[i]),
                .data_in(data_stage[i]),
                .valid_in(valid_stage[i]),
                .data_out(data_stage[i+1]),
                .valid_out(valid_stage[i+1])
            );
        end      
    endgenerate

    round_stage_dec_final round_stage_dec_final_inst
    (
        .aclk(aclk),
        .aresetn(aresetn),
        .en(s_axis_tready),
        .key(key[10]),
        .data_in(data_stage[10]),
        .valid_in(valid_stage[10]),
        .data_out(data_stage[11]),
        .valid_out(valid_stage[11])
    );  

    stage_dec_hand_m_axis stage_dec_hand_m_axis_inst
    (
        .aclk(aclk),
        .aresetn(aresetn),
        .data_in(data_stage[11]),
        .valid_in(valid_stage[11]),
        .m_axis_tdata(m_axis_tdata),
        .m_axis_tvalid(m_axis_tvalid),
        .m_axis_tready(m_axis_tready),
        .full(full)
    );

endmodule