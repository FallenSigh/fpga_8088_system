module clk_div_1p8432m (
    input  wire clk_50m,    // 50 MHz 系统输入时钟
    input  wire rst_n,      // 复位信号 (低电平有效)
    output reg  clk_out     // 1.8432 MHz 输出时钟
);

    // 参数定义：基于 50MHz -> 1.8432MHz 的精确分数比率
    // 计算公式: (1.8432MHz * 2) / 50MHz = 1152 / 15625
    localparam CNT_ADD = 1152;      // 累加步长
    localparam CNT_MAX = 15625;     // 累加周期 (模数)

    // 寄存器定义
    // 15625 需要 14位宽 (2^14 = 16384)，为了安全我们可以给 15位或更多
    reg [14:0] acc_cnt;

    always @(posedge clk_50m or negedge rst_n) begin
        if (!rst_n) begin
            acc_cnt <= 0;
            clk_out <= 0;
        end else begin
            // 累加器逻辑
            if (acc_cnt >= (CNT_MAX - CNT_ADD)) begin
                // 如果下一次累加会溢出周期
                acc_cnt <= acc_cnt + CNT_ADD - CNT_MAX;
                clk_out <= ~clk_out; // 翻转输出，产生时钟沿
            end else begin
                // 否则继续累加
                acc_cnt <= acc_cnt + CNT_ADD;
            end
        end
    end

endmodule
