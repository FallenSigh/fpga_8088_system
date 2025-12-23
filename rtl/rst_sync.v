module rst_sync (
    input  wire clk,       // 系统时钟
    input  wire rst_n_in,  // 外部输入的异步复位 (低电平有效)
    output wire rst_n_out  // 同步化后的复位信号 (输给内部逻辑)
);

    reg rst_n_d1, rst_n_d2;

    always @(posedge clk or negedge rst_n_in) begin
        if (!rst_n_in) begin
            // 异步复位：一旦输入拉低，输出立刻拉低
            rst_n_d1 <= 1'b0;
            rst_n_d2 <= 1'b0;
        end else begin
            // 同步释放：输入变高后，打两拍，随此时钟域释放
            rst_n_d1 <= 1'b1;
            rst_n_d2 <= rst_n_d1;
        end
    end

    assign rst_n_out = rst_n_d2;

endmodule
