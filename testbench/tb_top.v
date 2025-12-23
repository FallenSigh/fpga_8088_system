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

    wire [19:0] test_cpu_addr;
    wire [13:0] test_ram_addr;
    wire [13:0] test_rom_addr;
    wire [7:0] test_ram_data;
    wire [7:0] test_rom_data;
    wire [7:0] test_ram_wdata;
    wire test_clk_1m;
    wire test_pit_out0;
    wire [7:0] test_ppi_aout;
    wire [7:0] test_ppi_bout;
    wire [7:0] test_ppi_cout;
    wire test_cpu_intr;
    wire test_cpu_inta_n;
    wire test_ram_wren;
    wire test_ppi_cs;
    wire test_pic_cs;
    wire test_pit_cs;
    wire test_iorc_n;
    wire test_iowc_n;
    wire test_mwtc_n;
    wire test_mrdc_n;
    wire test_uart_tx;
    wire test_uart_rx;
    wire [2:0] test_cpu_s;

    // =========================
    // DUT 实例化
    // =========================
    mpe dut (
        .clk   (clk),
        .rst_n (rst_n),

        .test_cpu_addr(test_cpu_addr),
        .test_ram_addr(test_ram_addr),
        .test_rom_addr(test_rom_addr),
        .test_ram_data(test_ram_data),
        .test_rom_data(test_rom_data),
        .test_ram_wdata(test_ram_wdata),
        .test_clk_1m(test_clk_1m),
        .test_pit_out0(test_pit_out0),
        .test_ppi_aout(test_ppi_aout),
        .test_ppi_bout(test_ppi_bout),
        .test_ppi_cout(test_ppi_cout),
        .test_cpu_intr(test_cpu_intr),
        .test_cpu_inta_n(test_cpu_inta_n),
        .test_ram_wren(test_ram_wren),
        .test_ppi_cs(test_ppi_cs),
        .test_pic_cs(test_pic_cs),
        .test_pit_cs(test_pit_cs),
        .test_iorc_n(test_iorc_n),
        .test_iowc_n(test_iowc_n),
        .test_mwtc_n(test_mwtc_n),
        .test_mrdc_n(test_mrdc_n),
        .test_uart_tx(test_uart_tx),
        .test_uart_rx(test_uart_rx),
        .test_cpu_s(test_cpu_s)
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

        # 20000;

        $display("Simulation finished.");
        $stop;
    end

endmodule
