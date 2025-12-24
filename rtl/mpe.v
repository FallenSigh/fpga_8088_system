module mpe (
    input wire clk,
    input wire rst_n,

    output wire [3:0] led,
   	output wire stcp,
	output wire shcp,
	output wire ds,
	output wire oe,
	output wire uart_tx,
	input  wire uart_rx,

    output wire [19:0] test_cpu_addr,
    output wire [13:0] test_ram_addr,
    output wire [13:0] test_rom_addr,
    output wire [7:0] test_ram_data,
    output wire [7:0] test_rom_data,
    output wire [7:0] test_ram_wdata,
    output wire test_clk_1m,
    output wire test_pit_out0,
    output wire [7:0] test_ppi_aout,
    output wire [7:0] test_ppi_bout,
    output wire [7:0] test_ppi_cout,
    output wire test_cpu_intr,
    output wire test_cpu_inta_n,
    output wire test_ram_wren,
    output wire test_ppi_cs,
    output wire test_pic_cs,
    output wire test_pit_cs,
    output wire test_iorc_n,
    output wire test_iowc_n,
    output wire test_mwtc_n,
    output wire test_mrdc_n,
    output wire test_uart_tx,
    output wire test_uart_rx,
    output wire [2:0] test_cpu_s,
    output wire [7:0] test_seg,
    output wire [5:0] test_sel,
    output wire [3:0] test_led
);

    wire [19:0] cpu_addr;
    wire        cpu_ale;
    wire        cpu_den_n;
    wire [ 7:0] cpu_din;
    wire [ 7:0] cpu_dout;
    wire        cpu_dtr_n;
    wire        cpu_hlda;
    wire        cpu_hold;
    wire        cpu_inta_n;
    wire        cpu_intr;
    wire        cpu_iom;
    wire        cpu_lock_n;
    wire        cpu_nmi;
    wire [ 1:0] cpu_qs;
    wire        cpu_rd_n;
    wire        cpu_ready;
    wire        cpu_reset_o;
    wire [ 2:0] cpu_s;
    wire        cpu_test_n;
    wire        cpu_wr_n;
    wire [13:0] ram_addr;
    wire [ 7:0] ram_data;
    wire [ 7:0] ram_q;
    wire        ram_wren;
    wire [13:0] rom_addr;
    wire [ 7:0] rom_q;
    wire        sys_clk;
    wire        sys_rst;
    wire        srst_n;

    wire iorc_n;
    wire iowc_n;
    wire mrdc_n;
    wire mwtc_n;

    wire        pic_cs_n;
    wire        pic_a0;
    wire [ 7:0] pic_din;
    wire [ 7:0] pic_dout;
    wire        pic_inta_n;
    wire        pic_intr;
    wire [ 7:0] ir;

    wire        clk_1m;
    wire [ 7:0] pit_din;
    wire        pit_tmode;
    wire [ 7:0] pit_dout;
    wire        pit_clk0;
    wire        pit_clk1;
    wire        pit_clk2;
    wire        pit_dela0;
    wire        pit_delb0;
    wire        pit_delsel0;
    wire        pit_dela1;
    wire        pit_delb1;
    wire        pit_delsel1;
    wire        pit_dela2;
    wire        pit_delb2;
    wire        pit_delsel2;
    wire        pit_gate0;
    wire        pit_gate1;
    wire        pit_gate2;
    wire        pit_trig0;
    wire        pit_trig1;
    wire        pit_trig2;
    wire        pit_a0;
    wire        pit_a1;
    wire        pit_cs_n;
    wire        pit_noe;
    wire        pit_nod;
    wire        pit_out0;
    wire        pit_out1;
    wire        pit_out2;

    wire        ppi_cs_n;
    wire [ 1:0] ppi_addr;
    wire [ 7:0] ppi_din;
    wire [ 7:0] ppi_dout;
    wire [ 7:0] ppi_ain;
    wire [ 7:0] ppi_bin;
    wire [ 7:0] ppi_cin;
    wire [ 7:0] ppi_aout;
    wire [ 7:0] ppi_bout;
    wire [ 7:0] ppi_cout;

    wire clk_18432;
    wire [2:0] uart_addr;
    wire [7:0] uart_din;
    wire [7:0] uart_dout;
    wire uart_cs_n;
    wire uart_ndcd;
    wire uart_nri;
    wire uart_ndsr;
    wire uart_ncts;
    wire uart_rxd;
    wire uart_rclk_baud;
    wire uart_brge;
    wire uart_irq;
    wire uart_txd;

    // DMA interface signals
    wire        dma_cs_n;        // DMA chip select (buffer std_logic)
    wire [3:0]  dma_ain;         // DMA register access address
    wire [7:0]  dma_din;         // DMA data input
    wire [7:0]  dma_dout;        // DMA data output / Address[15:8] / Temp. data
    wire        dma_mrdc_n;       // DMA Memory Read
    wire        dma_mwtc_n;       // DMA Memory Write
    wire        dma_iorc_n;       // DMA I/O Read
    wire        dma_iowc_n;       // DMA I/O Write
    wire        dma_aen;          // DMA Address Enable
    wire        dma_dben;         // DMA Data Bus Enable
    wire        dma_adstb;        // DMA Address Strobe
    wire [3:0]  dma_dack;        // DMA acknowledge bus
    wire [7:0]  dma_aout;        // DMA address output
    wire [3:0]  dma_dreq;

    // 数码管
    wire [5:0] sel;
    wire [7:0] seg;

    assign test_cpu_addr = cpu_addr;
    assign test_ram_addr = ram_addr;
    assign test_rom_addr = rom_addr;
    assign test_ram_data = ram_q;
    assign test_rom_data = rom_q;
    assign test_ram_wdata = ram_data;
    assign test_clk_1m = clk_1m;
    assign test_pit_out0 = pit_out0;
    assign test_ppi_aout = ppi_aout;
    assign test_ppi_bout = ppi_bout;
    assign test_ppi_cout = ppi_cout;
    assign test_cpu_intr = cpu_intr;
    assign test_cpu_inta_n = cpu_inta_n;
    assign test_ram_wren = ram_wren;
    assign test_ppi_cs = ppi_cs_n;
    assign test_pic_cs = pic_cs_n;
    assign test_pit_cs = pit_cs_n;
    assign test_iorc_n = iorc_n;
    assign test_iowc_n = iowc_n;
    assign test_mwtc_n = mwtc_n;
    assign test_mrdc_n = mrdc_n;
    assign test_uart_tx = uart_txd;
    assign test_uart_rx = uart_rxd;
    assign test_cpu_s = cpu_s;
    assign test_seg = seg;
    assign test_sel = sel;
    assign test_led = led;

    assign uart_tx = uart_txd;
    assign uart_rxd = uart_rx;
    assign seg = ppi_aout;
    assign sel = ppi_bout[5:0];
    assign led = ppi_cout[3:0];
    assign pit_clk0 = clk_1m;
    assign pit_clk1 = clk_1m;
    assign pit_clk2 = clk_1m;
    assign ir = {1'b0, 1'b0, 1'b0, uart_irq, 1'b0, 1'b0, 1'b0, pit_out0};
    assign srst_n = ~cpu_reset_o;
    assign ppi_ain = 8'hfe;
    assign ppi_bin = 8'hff;
    assign ppi_cin = 8'hff;

    gw8088 gw8088_inst (
        .CLK(sys_clk),
        .RESET_N(sys_rst),
        .READY(cpu_ready),
        .TEST_N(cpu_test_n),
        .NMI(cpu_nmi),
        .INTR(cpu_intr),
        .HOLD(cpu_hold),
        .DIN(cpu_din),
        .IOM(cpu_iom),
        .RD_N(cpu_rd_n),
        .WR_N(cpu_wr_n),
        .A(cpu_addr),
        .DOUT(cpu_dout),
        .ALE(cpu_ale),
        .INTA_N(cpu_inta_n),
        .DTR_N(cpu_dtr_n),
        .DEN_N(cpu_den_n),
        .HLDA(cpu_hlda),
        .LOCK_N(cpu_lock_n),
        .RESET_O(cpu_reset_o),
        .S(cpu_s),
        .QS(cpu_qs)
    );

    system_bus bus_inst (
        .cpu_rd_n(cpu_rd_n),
        .cpu_wr_n(cpu_wr_n),
        .cpu_iom(cpu_iom),
        .cpu_addr(cpu_addr),
        .cpu_dout(cpu_dout),
        .cpu_inta_n(cpu_inta_n),
        .cpu_din(cpu_din),

        .iorc_n(iorc_n),
        .iowc_n(iowc_n),
        .mrdc_n(mrdc_n),
        .mwtc_n(mwtc_n),

        .ram_q(ram_q),
        .rom_q(rom_q),
        .ram_wren(ram_wren),
        .ram_addr(ram_addr),
        .ram_data(ram_data),
        .rom_addr(rom_addr),

        .pic_cs_n(pic_cs_n),
        .pic_a0(pic_a0),
        .pic_din(pic_din),
        .pic_dout(pic_dout),
        .pic_inta_n(pic_inta_n),

        .pit_cs_n(pit_cs_n),
        .pit_a0(pit_a0),
        .pit_a1(pit_a1),
        .pit_din(pit_din),
        .pit_dout(pit_dout),

        .ppi_cs_n(ppi_cs_n),
        .ppi_addr(ppi_addr),
        .ppi_din(ppi_din),
        .ppi_dout(ppi_dout),

        .uart_din(uart_din),
        .uart_dout(uart_dout),
        .uart_addr(uart_addr),
        .uart_cs_n(uart_cs_n)
    );

    gw8237 gw8237_inst(
      .RESET(cpu_reset_o),
      .CLK(sys_clk),
      .nCS(dma_cs_n),
      .nIORIN(iorc_n),
      .nIOWIN(iowc_n),
      .READY(1'b1),
      .HLDA(cpu_hlda),
      .nEOPIN(1'b1),
      .AIN(dma_ain),
      .DREQ(dma_dreq),
      .DBIN(dma_din),
      .DBOUT(dma_dout),
      .DBEN(dma_dben),
      .AOUT(dma_aout),
      .HRQ(cpu_hold),
      .DACK(dma_dack),
      .AEN(dma_aen),
      .ADSTB(dma_adstb),
      .nIOROUT(dma_iorc_n),
      .nIOWOUT(dma_iowc_n),
      .nMEMR(dma_mrdc_n),
      .nMEMW(dma_mwtc_n),
      .nEOPOUT(),
      .DMAENABLE()
    );

    clk_div_1p8432m uart_clk_inst(
        .clk_50m(sys_clk),      // 50 MHz 输入时钟
        .rst_n(sys_rst),          // 低有效复位
        .clk_out(clk_18432)    // 1.8432 MHz 输出
    );

    gw16550 gw16550_inst(
      .CLK(sys_clk),
      .RCLK(sys_clk),
      .MR(cpu_reset_o),
      .A(uart_addr),
      .DI(uart_din),
      .NCE(uart_cs_n),
      .NRD(iorc_n),
      .RD(~iorc_n),
      .NWR(iowc_n),
      .NDCD(uart_ndcd),
      .NRI(uart_nri),
      .NDSR(uart_ndsr),
      .NCTS(uart_ncts),
      .SIN(uart_rxd),
      .RCLK_BAUD(uart_rclk_baud),
      .BRGE(uart_brge),
      .DA(uart_dout),
      .IRQ(uart_irq),
      .SOUT(uart_txd),
      .NDVL(),
      .NOUT2(),
      .NOUT1(),
      .NRTS(),
      .NDTR(),
      .BAUD(),
      .TXRDY(),
      .RXRDY()
    );

    gw8255 gw8255_inst (
        .RESET(cpu_reset_o),
        .CLK(sys_clk),
        .nCS(ppi_cs_n),
        .nRD(iorc_n),
        .nWR(iowc_n),
        .A(ppi_addr),
        .DIN(ppi_din),
        .DOUT(ppi_dout),
        .PAIN(ppi_ain),
        .PBIN(ppi_bin),
        .PCIN(ppi_cin),
        .PAOUT(ppi_aout),
        .PBOUT(ppi_bout),
        .PCOUT(ppi_cout),
        .PAEN(),
        .PBEN(),
        .PCEN()
    );

    gw8259 gw8259_inst (
        .nMRST(srst_n),
        .CLK(sys_clk),
        .nCS(pic_cs_n),
        .nWR(iowc_n),
        .nRD(iorc_n),
        .A0(pic_a0),
        .nINTA(pic_inta_n),
        .nSP(1'b1),
        .CASIN(3'b000),
        .DIN(pic_din),
        .INT(cpu_intr),
        .CASOUT(),
        .CAS_EN(),
        .DOUT(pic_dout),
        .nEN(1'b0),
        .IR(ir)
    );

    gw8254 gw8254_inst (
        .ID(pit_din),
        .TMODE(pit_tmode),
        .CLK0(pit_clk0),
        .DELA0(pit_dela0),
        .DELB0(pit_delb0),
        .DELSEL0(pit_delsel0),
        .GATE0(pit_gate0),
        .TRIG0(pit_trig0),
        .CLK1(pit_clk1),
        .DELA1(pit_dela1),
        .DELB1(pit_delb1),
        .DELSEL1(pit_delsel1),
        .GATE1(pit_gate1),
        .TRIG1(pit_trig1),
        .CLK2(pit_clk2),
        .DELA2(pit_dela2),
        .DELB2(pit_delb2),
        .DELSEL2(pit_delsel2),
        .GATE2(pit_gate2),
        .TRIG2(pit_trig2),
        .A0(pit_a0),
        .A1(pit_a1),
        .NCLR(srst_n),
        .NCS(pit_cs_n),
        .NWR(iowc_n),
        .NRD(iorc_n),
        .NOE(iorc_n),
        .DAO(pit_dout),
        .NOD(pit_nod),
        .OUT0(pit_out0),
        .OUT1(pit_out1),
        .OUT2(pit_out2)
    );


    pll pll_inst (
        .inclk0(clk),
        .c0(sys_clk)
    );

    pit_clk_div pit_clk_inst (
        .clk_50m(sys_clk),
        .rst_n  (rst_n),
        .pit_clk(clk_1m)
    );

    ram ram_inst (
        .clock(sys_clk),
        .wren(ram_wren),
        .address(ram_addr),
        .data(ram_data),
        .q(ram_q)
    );

    rom rom_inst (
        .clock(sys_clk),
        .address(rom_addr),
        .q(rom_q)
    );

    rst_sync rst_sync_inst (
        .clk(clk),
        .rst_n_in(rst_n),
        .rst_n_out(sys_rst)
    );


 //    seg_595_dynamic seg_inst(
	// 	.sys_clk(clk),
	// 	.sys_rst_n(rst_n),
	// 	.data(seg_data),
	// 	.point(6'b0),
	// 	.seg_en(1'b1),
	// 	.sign(1'b0),
	// 	.stcp(stcp),
	// 	.shcp(shcp),
	// 	.ds(ds),
	// 	.oe(oe)
	// );

	hc595_ctrl hc595_inst(
		.sys_clk(clk),
		.sys_rst_n(rst_n),
		.sel(sel),
		.seg(seg),
		.stcp(stcp),
		.shcp(shcp),
		.ds(ds),
		.oe(oe)
	);

    assign cpu_nmi = 0;
    assign cpu_ready = 1;
    assign cpu_test_n = 0;

    assign dma_dreq = 4'b0;
    assign pit_tmode = 0;
    assign pit_dela0 = 0;
    assign pit_delb0 = 0;
    assign pit_delsel0 = 0;
    assign pit_dela1 = 0;
    assign pit_delb1 = 0;
    assign pit_delsel1 = 0;
    assign pit_dela2 = 0;
    assign pit_delb2 = 0;
    assign pit_delsel2 = 0;
    assign pit_gate0 = 1;
    assign pit_gate1 = 1;
    assign pit_gate2 = 1;
    assign pit_trig0 = pit_gate0;
    assign pit_trig1 = pit_gate1;
    assign pit_trig2 = pit_gate2;

    assign uart_ndcd = 1'b1;
    assign uart_nri = 1'b1;
    assign uart_ndsr = 1'b1;
    assign uart_ncts = 1'b1;
    assign uart_rclk_baud = 1'b1;
    assign uart_brge = 1'b1;

endmodule
