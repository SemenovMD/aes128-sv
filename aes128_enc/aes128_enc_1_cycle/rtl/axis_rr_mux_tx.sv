module axis_rr_mux_tx

#(
    parameter CORE = 44
)

(
    input   logic               aclk,
    input   logic               aresetn,

    input   logic   [127:0]     s_axis_tdata    [0:CORE-1],
    input   logic   [CORE-1:0]  s_axis_tvalid,
    output  logic   [CORE-1:0]  s_axis_tready,

    output  logic   [127:0]     m_axis_tdata,
    output  logic               m_axis_tvalid,
    input   logic               m_axis_tready
);

    localparam COUNTER_WIDTH = $clog2(CORE);

    logic [127:0]   mem [0:CORE-1];

    logic [COUNTER_WIDTH-1:0]   wr_ptr, rd_ptr;
    logic [COUNTER_WIDTH:0]     item_count;

    logic [127:0]               s_axis_tdata_reg;
    
    logic full, empty;
    logic wr_en, rd_en;

    assign wr_en = s_axis_tvalid[wr_ptr] && !full;
    assign rd_en = m_axis_tready && !empty;
    assign full  = (item_count == CORE);
    assign empty = (item_count == 'd0);

    always_ff @(posedge aclk) begin
        if (!aresetn) begin
            wr_ptr <= 'd0;
            rd_ptr <= 'd0;
            item_count <= 'd0;
            s_axis_tready <= 'd0;
            m_axis_tvalid <= 'd0;
            m_axis_tdata <= '0;
        end else begin
            if (wr_en) begin
                mem[wr_ptr] <= s_axis_tdata_reg;
                if (wr_ptr == CORE-1) begin
                    wr_ptr <= 'd0;
                end else begin
                    wr_ptr <= wr_ptr + 1'b1;
                end
            end
            
            if (rd_en) begin
                m_axis_tdata <= mem[rd_ptr];
                m_axis_tvalid <= 1'b1;
                if (rd_ptr == CORE-1) begin
                    rd_ptr <= 'd0;
                end else begin
                    rd_ptr <= rd_ptr + 1'b1;
                end
            end else if (empty) begin
                m_axis_tvalid <= 1'b0;
            end
            
            case ({wr_en, rd_en})
                2'b00, 2'b11: item_count <= item_count;
                2'b01: item_count <= item_count - 1'b1;
                2'b10: item_count <= item_count + 1'b1;
            endcase
            
            s_axis_tready <= 'd0;
            if (!full) begin
                s_axis_tready[wr_ptr] <= 1'b1;
            end
        end
    end

    always_comb begin
        s_axis_tdata_reg = 128'd0;
        s_axis_tdata_reg = s_axis_tdata[wr_ptr];
    end

endmodule