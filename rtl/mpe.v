module mpe(
	clk,
	rst_n,
	ir,
	test_addr,
	test_ram_addr,
	test_rom_addr,
	test_ram_cs,
	test_rom_cs,
	test_ram_data,
	test_rom_data,
	test_pic_cs,
	test_pic_din,
	test_pic_dout,
	test_out,
	test_cpu_s,
	test_ram_wren,
	test_ram_wdata,
	test_pic_int,
	test_cpu_inta_n
);


input wire	clk;
input wire	rst_n;
input wire [7:0] ir;
output wire [19:0] test_addr;
output wire [13:0] test_ram_addr;
output wire [13:0] test_rom_addr;
output wire [7:0] test_ram_data;
output wire [7:0] test_rom_data;
output wire test_ram_cs;
output wire test_rom_cs;
output wire test_pic_cs;
output wire [7:0] test_pic_din;
output wire [7:0] test_pic_dout;
output wire [7:0]  test_out;
output wire [2:0] test_cpu_s;
output wire test_ram_wren;
output wire [7:0] test_ram_wdata;
output wire test_pic_int;
output wire test_cpu_inta_n;

wire	[19:0] cpu_addr;
assign test_addr = cpu_addr;
wire	cpu_ale;
wire	cpu_den_n;
wire	[7:0] cpu_din;
wire	[7:0] cpu_dout;
wire	cpu_dtr_n;
wire	cpu_hlda;
wire	cpu_hold;
wire	cpu_inta_n;
wire	cpu_intr;
wire	cpu_iom;
wire	cpu_lock_n;
wire	cpu_nmi;
wire	[1:0] cpu_qs;
wire	cpu_rd_n;
wire	cpu_ready;
wire	cpu_reset_o;
wire	[2:0] cpu_s;
wire	cpu_test_n;
wire	cpu_wr_n;
wire	[13:0] ram_addr;
wire	[7:0] ram_data;
wire	[7:0] ram_q;
wire	ram_wren;
wire	[13:0] rom_addr;
wire	[7:0] rom_q;
wire	sys_clk;
wire	sys_rst;

wire        pic_cs_n;
wire        pic_rd_n;
wire        pic_wr_n;
wire        pic_a0;
wire [7:0]  pic_din;
wire [7:0]  pic_dout;

wire  clk_1m;
wire [7:0] pit_din;
wire [5:0] pit_tmode;
wire [7:0] pit_dao;
wire pit_clk0;
wire pit_clk1;
wire pit_clk2;
wire pit_dela0;
wire pit_delb0;
wire pit_delsel0;
wire pit_dela1;
wire pit_delb1;
wire pit_delsel1;
wire pit_dela2;
wire pit_delb2;
wire pit_delsel2;
wire pit_gate0;
wire pit_gate1;
wire pit_gate2;
wire pit_trig0;
wire pit_trig1;
wire pit_trig2;
wire pit_nclr;
wire pit_a0;
wire pit_a1;
wire pit_ncs;
wire pit_nwr;
wire pit_nrd;
wire pit_noe;
wire pit_nod;
wire pit_out0;
wire pit_out1;
wire pit_out2;

assign test_ram_addr = ram_addr;
assign test_rom_addr = rom_addr;
assign test_ram_data = ram_q;
assign test_ram_wdata = ram_data;
assign test_rom_data = rom_q;
assign test_pic_cs = pic_cs_n;
assign test_pic_din = pic_din;
assign test_pic_dout = pic_dout;
assign test_cpu_s = cpu_s;

gw8088	gw8088_inst(
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


system_bus	bus_inst(
	.cpu_rd_n(cpu_rd_n),
	.cpu_wr_n(cpu_wr_n),
	.cpu_iom(cpu_iom),
	.cpu_addr(cpu_addr),
	.cpu_dout(cpu_dout),
	.cpu_inta_n(cpu_inta_n),
	.cpu_intr(cpu_intr),
	.ram_q(ram_q),
	.rom_q(rom_q),
	.ram_wren(ram_wren),
	.cpu_din(cpu_din),
	.ram_addr(ram_addr),
	.ram_data(ram_data),
	.rom_addr(rom_addr),
	.pic_cs_n(pic_cs_n),
	.pic_rd_n(pic_rd_n),
	.pic_wr_n(pic_wr_n),
	.pic_a0(pic_a0),
	.pic_din(pic_din),
	.pic_dout(pic_dout),
	.pic_inta_n(pic_inta_n),
	.pic_intr(pic_intr),
	.test_rom_cs(test_rom_cs),
	.test_ram_cs(test_ram_cs),
	.test_out(test_out),
	.test_ram_wren(test_ram_wren),
	.test_pic_int(test_pic_int),
	.test_cpu_inta_n(test_cpu_inta_n)
	);

gw8259 gw8259_inst(
  .nMRST(sys_rst),
  .CLK(sys_clk),
  .nCS(pic_cs_n),
  .nWR(pic_wr_n),
  .nRD(pic_rd_n),
  .A0(pic_a0),
  .nINTA(pic_inta_n),
  .nSP(1'b1),
  .CASIN(3'b000),
  .DIN(pic_din),
  .INT(pic_intr),
  .CASOUT(),
  .CAS_EN(),
  .DOUT(pic_dout),
  .nEN(1'b0),
  .IR(ir)
);

assign pit_clk0 = pit_clk;
assign pit_clk1 = pit_clk;
assign pit_clk2 = pit_clk;

gw8254 gw8254_inst(
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
  .NCLR(pit_nclr),
  .NCS(pit_ncs),
  .NWR(pit_nwr),
  .NRD(pit_nrd),
  .NOE(pit_noe),
  .DAO(pit_dao),
  .NOD(pit_nod),
  .OUT0(pit_out0),
  .OUT1(pit_out1),
  .OUT2(pit_out2)
);


pll	pll_inst(
	.inclk0(clk),
	.c0(sys_clk)
);

pit_clk_div pit_clk_inst(
	.clk_50m(sys_clk),
	.rst_n(rst_n),
	.pit_clk(clk_1m)
);


ram	ram_inst(
	.clock(sys_clk),
	.wren(ram_wren),
	.address(ram_addr),
	.data(ram_data),
	.q(ram_q)
);


rom	rom_inst(
	.clock(sys_clk),
	.address(rom_addr),
	.q(rom_q)
);


rst_sync	rst_sync_inst(
	.clk(clk),
	.rst_n_in(rst_n),
	.rst_n_out(sys_rst)
);

assign	cpu_hold = 0;
assign	cpu_nmi = 0;
assign	cpu_ready = 1;
assign	cpu_test_n = 0;

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

endmodule
