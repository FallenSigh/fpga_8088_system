module system_bus(
    // CPU 侧控制信号
    input  wire         cpu_rd_n,      // CPU 读选通 (低电平有效)
    input  wire         cpu_wr_n,      // CPU 写选通 (低电平有效)
    input  wire         cpu_iom,       // IO/Memory 选择 (1=IO, 0=Memory)
    input  wire [19:0]  cpu_addr,      // 20位地址总线
    input  wire [7:0]   cpu_dout,      // CPU 输出的数据 (用于写入 RAM/IO)
    output wire [7:0]   cpu_din,       // CPU 输入的数据 (从 RAM/ROM/IO 读取)
    input               pic_intr,      // 中断请求信号 (来自 PIC)
    output wire         cpu_intr,

    // CPU 中断请求信号 (低电平有效)
    input  wire         cpu_inta_n,

    // 外设数据输入 (从外设读出的数据)
    input  wire [7:0]   ram_q,         // RAM 数据输出
    input  wire [7:0]   rom_q,         // ROM 数据输出
    input  wire [7:0]   pic_dout,      // PIC (8259) 数据输出

    // RAM 控制信号
    output wire         ram_wren,      // RAM 写使能 (高电平有效)
    output wire [13:0]  ram_addr,      // RAM 地址 (16KB -> 14位)
    output wire [7:0]   ram_data,      // 写给 RAM 的数据

    // ROM 控制信号
    output wire [13:0]  rom_addr,      // ROM 地址 (16KB -> 14位)

    // PIC (8259) 控制信号
    output wire         pic_cs_n,      // PIC 片选 (低电平有效)
    output wire         pic_rd_n,      // PIC 读选通
    output wire         pic_wr_n,      // PIC 写选通
    output wire         pic_a0,        // PIC 寄存器选择 (地址位0)
    output wire [7:0]   pic_din,       // 写给 PIC 的数据
    output wire         pic_inta_n,    // 中断响应信号 (给 PIC)

    // PIT (8254) 控制信号
    output wire        pit_cs_n,
    output wire        pit_rd_n,
    output wire        pit_wr_n,
    output wire        pit_a0,
    output wire        pit_a1,
    output wire [7:0]  pit_din,
    input  wire [7:0] pit_dout,

    // 测试与观测信号
    output wire         test_rom_cs,   // ROM 片选测试点
    output wire         test_ram_cs,   // RAM 片选测试点
    output wire [7:0]   test_out,      // 测试输出端口
    output wire         test_ram_wren,  // RAM 写使能测试点
    output wire         test_pic_int,
    output wire         test_cpu_inta_n,
    output wire         test_pit_cs
);

    // 地址译码逻辑 (Address Decoding)

    // 内部片选信号 (高电平表示选中)
    wire ram_cs;
    wire rom_cs;
    wire pic_cs;
    wire pit_cs;



    // RAM: 0x00000 - 0x03FFF
    // cpu_iom = 0 (Memory), A19..A14 = 000000
    assign ram_cs = (cpu_iom == 1'b0) && (cpu_addr[19:14] == 6'b000000);

    // ROM: 0xFC000 - 0xFFFFF
    // cpu_iom = 0 (Memory), A19..A14 = 111111 (0x3F)
    assign rom_cs = (cpu_iom == 1'b0) && (cpu_addr[19:14] == 6'b111111);

    // PIC (8259): IO Space, Address 0x20 - 0x21
    // 这里采用简化的 IO 译码：A7..A4 = 0010 (0x2x)
    assign pic_cs = (cpu_iom == 1'b1) && (cpu_addr[7:4] == 4'b0010);

    // PIT (8254): IO Space, Address 0x40 - 0x43
    // 这里采用简化的 IO 译码：A7..A4 = 0100 (0x4x)
    assign pit_cs = (cpu_iom == 1'b1) && (cpu_addr[7:4] == 4'b0100);

    // Test Output (IO Space, Address 0x56)
    assign testout_cs = (cpu_iom == 1'b1) && (cpu_addr == 20'h56);

    // 输出信号分配 (Output Assignments)

    // RAM 接口
    assign ram_addr = cpu_addr[13:0]; // 16KB 空间映射
    assign ram_data = cpu_dout;       // 写数据直接来源于 CPU
    assign ram_wren = ram_cs && (!cpu_wr_n); // 写使能：选中 RAM 且 CPU 执行写操作 (WR_N=0)

    // ROM 接口
    assign rom_addr = cpu_addr[13:0]; // 16KB 空间映射

    // PIC (8259) 接口
    assign pic_cs_n = !pic_cs;        // Active Low
    assign pic_rd_n = cpu_rd_n;       // 直接透传 CPU 读信号
    assign pic_wr_n = cpu_wr_n;       // 直接透传 CPU 写信号
    assign pic_a0   = cpu_addr[0];    // A0 用于区分命令字/数据字
    assign pic_din  = cpu_dout;       // 写数据直接来源于 CPU
    assign cpu_intr = pic_intr;       // 中断请求信号直接来源于 PIC
    assign pic_inta_n = cpu_inta_n;   // 中断应答信号直接来源于 CPU

    // PIT (8254) 接口
    assign pit_cs_n = ~pit_cs;
    assign pit_rd_n = cpu_rd_n;       // 直接透传 CPU 读信号
    assign pit_wr_n = cpu_wr_n;       // 直接透传 CPU 写信号
    assign pit_a0   = cpu_addr[0];    // A0 用于区分命令字/数据字
    assign pit_a1   = cpu_addr[1];    // A1 用于区分命令字/数据字
    assign pit_din  = cpu_dout;       // 写数据直接来源于 CPU

    // --- 测试信号 ---
    assign test_ram_cs   = !ram_cs;   // 输出低电平有效的 CS
    assign test_rom_cs   = !rom_cs;   // 输出低电平有效的 CS
    assign test_ram_wren = ram_wren;
    assign test_out      = (testout_cs && !cpu_wr_n) ? cpu_dout : 8'h00;   // 将 CPU 读到的数据输出到测试端口
    assign test_pic_int  = pic_intr;
    assign test_cpu_inta_n = cpu_inta_n;
    assign test_pit_cs = pit_cs_n;
    //=========================================================
    // 3. 数据总线多路复用 (Data Bus Multiplexer)
    //=========================================================

    // 根据片选信号和读信号，决定哪一个外设的数据送入 CPU
    // cpu_din 是 combinational logic
    assign cpu_din = (!cpu_inta_n) ? pic_dout :
                     (ram_cs && !cpu_rd_n) ? ram_q :     // 读 RAM
                     (rom_cs && !cpu_rd_n) ? rom_q :     // 读 ROM
                     (pic_cs && !cpu_rd_n) ? pic_dout :  // 读 PIC
                     (pit_cs && !cpu_rd_n) ? pit_dout :  // 读 PIT
                     8'h00;                              // 默认/空闲状态


endmodule
