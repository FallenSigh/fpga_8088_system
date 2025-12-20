module clk_1p8432m (
    input  wire clk_50m,      // 50 MHz 输入时钟
    input  wire rst_n,          // 低有效复位
    output reg  clk_1p8432m    // 1.8432 MHz 输出
);

    // 32 位相位累加器
    reg [31:0] phase_acc;

    // 1.8432MHz 对应的相位步进
    localparam [31:0] PHASE_STEP = 32'd158_329_674;

    always @(posedge clk_50m or negedge rst_n) begin
        if (!rst_n) begin
            phase_acc   <= 32'd0;
            clk_1p8432m <= 1'b0;
        end else begin
            phase_acc <= phase_acc + PHASE_STEP;

            // 最高位翻转输出（DDS 方波）
            clk_1p8432m <= phase_acc[31];
        end
    end

endmodule
