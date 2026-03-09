module aes128_pp_top_wrapper

#(
    parameter START_KEY = 128'h2B7E151628AED2A6ABF7158809CF4F3C
)

(
    input   wire            aclk,
    input   wire            aresetn,

    // Key
    input   wire    [127:0] s_axis_key_tdata,
    input   wire            s_axis_key_tvalid,
    output  wire            s_axis_key_tready,

    // Decryption
    input   wire    [127:0] s_axis_dec_tdata,
    input   wire            s_axis_dec_tvalid,
    output  wire            s_axis_dec_tready,
    output  wire    [127:0] m_axis_dec_tdata,
    output  wire            m_axis_dec_tvalid,
    input   wire            m_axis_dec_tready,

    // Encryption
    input   wire    [127:0] s_axis_enc_tdata,
    input   wire            s_axis_enc_tvalid,
    output  wire            s_axis_enc_tready,
    output  wire    [127:0] m_axis_enc_tdata,
    output  wire            m_axis_enc_tvalid,
    input   wire            m_axis_enc_tready
);

    aes128_pp_top #(.START_KEY(START_KEY)) aes128_pp_top_inst
    (
        .aclk(aclk),
        .aresetn(aresetn),
        .s_axis_key_tdata(s_axis_key_tdata),
        .s_axis_key_tvalid(s_axis_key_tvalid),
        .s_axis_key_tready(s_axis_key_tready),
        .s_axis_dec_tdata(s_axis_dec_tdata),
        .s_axis_dec_tvalid(s_axis_dec_tvalid),
        .s_axis_dec_tready(s_axis_dec_tready),
        .m_axis_dec_tdata(m_axis_dec_tdata),
        .m_axis_dec_tvalid(m_axis_dec_tvalid),
        .m_axis_dec_tready(m_axis_dec_tready),
        .s_axis_enc_tdata(s_axis_enc_tdata),
        .s_axis_enc_tvalid(s_axis_enc_tvalid),
        .s_axis_enc_tready(s_axis_enc_tready),
        .m_axis_enc_tdata(m_axis_enc_tdata),
        .m_axis_enc_tvalid(m_axis_enc_tvalid),
        .m_axis_enc_tready(m_axis_enc_tready)
    );

endmodule