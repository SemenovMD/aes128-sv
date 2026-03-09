module stage_dec_hand_m_axis

(
    input   logic           aclk,
    input   logic           aresetn,

    input   logic   [127:0] data_in,
    input   logic           valid_in,

    output  logic   [127:0] m_axis_tdata,
    output  logic           m_axis_tvalid,
    input   logic           m_axis_tready,

    output  logic           full
);

    always_ff @(posedge aclk) begin
        if (!aresetn) begin
            m_axis_tvalid <= 1'd0;
            full <= 1'd0;
        end else begin
            m_axis_tvalid <= valid_in;
            m_axis_tdata  <= data_in;
            full <= 1'd0;

            if (m_axis_tvalid) begin
                if (!m_axis_tready) begin
                    full <= 1'd1;
                end
            end
        end
    end

endmodule