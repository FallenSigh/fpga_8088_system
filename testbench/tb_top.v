`timescale 1ns / 1ps

module tb_top;

    // =========================
    // 仿真参数
    // =========================
    parameter CLK_PERIOD = 20;  // 50 MHz 时钟（20ns）

    // =========================
    // 仿真信号
    // =========================
    reg clk;
    reg rst_n;
    reg [6:0] ir;

    wire [19:0] test_addr;
    wire [13:0] test_ram_addr;
    wire [13:0] test_rom_addr;
    wire [7:0] test_rom_data;
    wire [7:0] test_ram_data;
    wire test_ram_cs;
    wire test_rom_cs;
    wire test_pic_cs;
    wire [7:0] test_pic_din;
    wire [7:0] test_pic_dout;
    wire [7:0] test_out;
    wire [2:0] test_cpu_s;
    wire test_ram_wren;
    wire [7:0] test_ram_wdata;
    wire test_pic_int;
    wire test_cpu_inta_n;
    wire test_pit_cs;
    wire test_clk_1m;
    wire test_pit_out0;

    // =========================
    // DUT 实例化
    // =========================
    mpe dut (
        .clk   (clk),
        .rst_n (rst_n),
        .ir_ext(ir),
        .test_addr(test_addr),
        .test_ram_addr(test_ram_addr),
        .test_rom_addr(test_rom_addr),
        .test_pic_din(test_pic_din),
        .test_pic_dout(test_pic_dout),
        .test_ram_data(test_ram_data),
        .test_rom_data(test_rom_data),
        .test_ram_cs(test_ram_cs),
        .test_rom_cs(test_rom_cs),
        .test_pic_cs(test_pic_cs),
        .test_out(test_out),
        .test_cpu_s(test_cpu_s),
        .test_ram_wren(test_ram_wren),
        .test_ram_wdata(test_ram_wdata),
        .test_pic_int(test_pic_int),
        .test_cpu_inta_n(test_cpu_inta_n),
        .test_pit_cs(test_pit_cs),
        .test_clk_1m(test_clk_1m),
        .test_pit_out0(test_pit_out0)
    );

    // =========================
    // 时钟产生
    // =========================
    initial begin
        clk = 1'b0;
        forever #(CLK_PERIOD / 2) clk = ~clk;
    end

    // =========================
    // 复位时序
    // =========================
    initial begin
        ir = 8'h0;
        rst_n = 1'b0;  // 上电复位
        #100;
        rst_n = 1'b1;  // 释放复位
    end

    // =========================
    // 仿真控制
    // =========================
    initial begin
        // 等待复位完成
        @(posedge rst_n);

        // 运行一段时间，观察 CPU 行为
        # 10000;
        ir = 8'h1;

        # 20000;

        $display("Simulation finished.");
        $stop;
    end

endmodule
