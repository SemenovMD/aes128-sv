module aes128_core_top

#(
    parameter START_KEY = 128'h2B7E151628AED2A6ABF7158809CF4F3C
)

(
    input   logic           aclk,
    input   logic           aresetn,

    // Key
    input   logic   [127:0] s_axis_key_tdata,
    input   logic           s_axis_key_tvalid,
    output  logic           s_axis_key_tready,

    // Decryption
    input   logic   [127:0] s_axis_dec_tdata,
    input   logic           s_axis_dec_tvalid,
    output  logic           s_axis_dec_tready,
    output  logic   [127:0] m_axis_dec_tdata,
    output  logic           m_axis_dec_tvalid,
    input   logic           m_axis_dec_tready,

    // Encryption
    input   logic   [127:0] s_axis_enc_tdata,
    input   logic           s_axis_enc_tvalid,
    output  logic           s_axis_enc_tready,
    output  logic   [127:0] m_axis_enc_tdata,
    output  logic           m_axis_enc_tvalid,
    input   logic           m_axis_enc_tready
);

    logic   [127:0] key_dec [0:10];
    logic   [127:0] key_enc [0:10];
    logic           core_aresetn;

    key_expansion #(.START_KEY(START_KEY)) key_expansion_inst
    (
        .aclk(aclk),
        .aresetn(aresetn),
        .s_axis_tdata(s_axis_key_tdata),
        .s_axis_tvalid(s_axis_key_tvalid),
        .s_axis_tready(s_axis_key_tready),
        .key_dec(key_dec),
        .key_enc(key_enc),
        .key_ready(core_aresetn)
    );

    aes128_dec_core aes128_dec_core_inst
    (
        .aclk(aclk),
        .aresetn(core_aresetn),
        .key(key_dec),
        .s_axis_tdata(s_axis_dec_tdata),
        .s_axis_tvalid(s_axis_dec_tvalid),
        .s_axis_tready(s_axis_dec_tready),
        .m_axis_tdata(m_axis_dec_tdata),
        .m_axis_tvalid(m_axis_dec_tvalid),
        .m_axis_tready(m_axis_dec_tready)
    );

    aes128_enc_core aes128_enc_core_inst
    (
        .aclk(aclk),
        .aresetn(core_aresetn),
        .key(key_enc),
        .s_axis_tdata(s_axis_enc_tdata),
        .s_axis_tvalid(s_axis_enc_tvalid),
        .s_axis_tready(s_axis_enc_tready),
        .m_axis_tdata(m_axis_enc_tdata),
        .m_axis_tvalid(m_axis_enc_tvalid),
        .m_axis_tready(m_axis_enc_tready)
    );

endmodule