module axis_rr_mux_rx

#(
    parameter CORE = 44
)

(
    input   logic               aclk,
    input   logic               aresetn,

    input   logic   [127:0]     s_axis_tdata,
    input   logic               s_axis_tvalid,
    output  logic               s_axis_tready,

    output  logic   [127:0]     m_axis_tdata,
    output  logic   [CORE-1:0]  m_axis_tvalid,
    input   logic   [CORE-1:0]  m_axis_tready
);

    localparam COUNTER_WIDTH = $clog2(CORE);
    
    logic   [COUNTER_WIDTH-1:0]   count;

    always_ff @(posedge aclk) begin
        if (!aresetn) begin
            count <= '0;
        end else begin
            if (s_axis_tready && s_axis_tvalid) begin
                if (count == CORE-1) begin
                    count <= '0;
                end else begin
                    count <= count + 1'd1;
                end
            end
        end
    end

    assign m_axis_tdata  = s_axis_tdata;

    always_comb begin
        m_axis_tvalid = '0;
        m_axis_tvalid[count] = s_axis_tvalid;
    end

    assign s_axis_tready = m_axis_tready[count];

endmodule