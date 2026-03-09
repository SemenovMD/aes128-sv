module stage_enc_hand_s_axis

(
    input   logic           aclk,
    input   logic           aresetn,

    input   logic   [127:0] s_axis_tdata,
    input   logic           s_axis_tvalid,
    output  logic           s_axis_tready,

    output  logic   [127:0] data_out,
    output  logic           data_valid,

    input   logic           full
);
    
    always_ff @(posedge aclk) begin
        if (!aresetn) begin
            s_axis_tready <= 1'd0;
            data_valid <= 1'd0;
        end else begin
            if (!full) begin
                s_axis_tready <= 1'd1;
                data_valid <= 1'd0;

                if (s_axis_tvalid && s_axis_tready) begin
                    data_out  <= s_axis_tdata;
                    data_valid <= 1'd1;
                end
            end else begin
                s_axis_tready <= 1'd0;
                data_valid <= 1'd0;
            end
        end
    end

endmodule