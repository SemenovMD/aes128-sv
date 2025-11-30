module aes128_enc_core_cluster 

#(
    parameter logic [127:0] KEY [0:10] = '{
        128'h2B7E151628AED2A6ABF7158809CF4F3C,
        128'hA0FAFE1788542CB123A339392A6C7605,
        128'hF2C295F27A96B9435935807A7359F67F,
        128'h3D80477D4716FE3E1E237E446D7A883B,
        128'hEF44A541A8525B7FB671253BDB0BAD00,
        128'hD4D1C6F87C839D87CAF2B8BC11F915BC,
        128'h6D88A37A110B3EFDDBF98641CA0093FD,
        128'h4E54F70E5F5FC9F384A64FB24EA6DC4F,
        128'hEAD27321B58DBAD2312BF5607F8D292F,
        128'hAC7766F319FADC2128D12941575C006E,
        128'hD014F9A8C9EE2589E13F0CC8B6630CA6
    },

    parameter CORE = 44
)

(
    // Global Signals
    input   logic           aclk,
    input   logic           aresetn,

    // AXI-Stream Slave
    input   logic   [127:0] s_axis_tdata,
    input   logic           s_axis_tvalid,
    output  logic           s_axis_tready,

    // AXI-Stream Master
    output  logic   [127:0] m_axis_tdata,
    output  logic           m_axis_tvalid,
    input   logic           m_axis_tready
);

    logic   [127:0]     m_axis_tdata_rx;
    logic   [CORE-1:0]  m_axis_tvalid_rx;
    logic   [CORE-1:0]  m_axis_tready_rx;

    logic   [127:0]     s_axis_tdata_tx    [0:CORE-1];
    logic   [CORE-1:0]  s_axis_tvalid_tx;
    logic   [CORE-1:0]  s_axis_tready_tx;

    genvar i;

    axis_rr_mux_rx #(.CORE(CORE)) axis_rr_mux_rx_inst
    (
        .aclk(aclk),
        .aresetn(aresetn),
        .s_axis_tdata(s_axis_tdata),
        .s_axis_tvalid(s_axis_tvalid),
        .s_axis_tready(s_axis_tready),
        .m_axis_tdata(m_axis_tdata_rx),
        .m_axis_tvalid(m_axis_tvalid_rx),
        .m_axis_tready(m_axis_tready_rx)
    );

    generate
        for (i = 0; i < CORE; i++) begin : gen_aes128_enc_core
            aes128_enc_core #(.KEY(KEY)) aes128_enc_core_inst 
            (
                .aclk(aclk),
                .aresetn(aresetn),
                .s_axis_tdata(m_axis_tdata_rx),
                .s_axis_tvalid(m_axis_tvalid_rx[i]),
                .s_axis_tready(m_axis_tready_rx[i]),
                .m_axis_tdata(s_axis_tdata_tx[i]),
                .m_axis_tvalid(s_axis_tvalid_tx[i]),
                .m_axis_tready(s_axis_tready_tx[i])
            );
        end
    endgenerate

    axis_rr_mux_tx #(.CORE(CORE)) axis_rr_mux_tx_inst
    (
        .aclk(aclk),
        .aresetn(aresetn),
        .s_axis_tdata(s_axis_tdata_tx),
        .s_axis_tvalid(s_axis_tvalid_tx),
        .s_axis_tready(s_axis_tready_tx),
        .m_axis_tdata(m_axis_tdata),
        .m_axis_tvalid(m_axis_tvalid),
        .m_axis_tready(m_axis_tready)
    );

endmodule