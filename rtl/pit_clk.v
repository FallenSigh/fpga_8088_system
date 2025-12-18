module pit_clk_div (
    input  wire clk_50m,   // 50 MHz 输入时钟
    input  wire rst_n,      // 低有效复位
    output reg  pit_clk     // 1 MHz 输出时钟
);

    // 50 MHz / 1 MHz = 50
    // 半周期 = 25 个 50MHz 时钟
    reg [5:0] cnt;          // 0~49 需要 6 位

    always @(posedge clk_50m or negedge rst_n) begin
        if (!rst_n) begin
            cnt     <= 6'd0;
            pit_clk <= 1'b0;
        end else begin
            if (cnt == 6'd24) begin
                pit_clk <= ~pit_clk;
                cnt     <= 6'd0;
            end else begin
                cnt <= cnt + 6'd1;
            end
        end
    end

endmodule
