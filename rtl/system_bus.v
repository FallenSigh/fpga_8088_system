module system_bus(
    // CPU 侧控制信号
    input  wire          cpu_rd_n,      // CPU 读选通 (低电平有效)
    input  wire          cpu_wr_n,      // CPU 写选通 (低电平有效)
    input  wire          cpu_iom,       // IO/Memory 选择 (1=IO, 0=Memory)
    input  wire [19:0]   cpu_addr,      // 20位地址总线
    input  wire [7:0]    cpu_dout,      // CPU 输出的数据 (用于写入 RAM/IO)
    output wire [7:0]    cpu_din,       // CPU 输入的数据 (从 RAM/ROM/IO 读取)

    // 系统总线控制信号 (仲裁后的输出)
    output wire iorc_n,
    output wire iowc_n,
    output wire mrdc_n,
    output wire mwtc_n,

    // CPU 中断请求信号 (低电平有效)
    input  wire          cpu_inta_n,

    // 外设数据输入 (从外设读出的数据)
    input  wire [7:0]    ram_q,         // RAM 数据输出
    input  wire [7:0]    rom_q,         // ROM 数据输出
    input  wire [7:0]    pic_dout,      // PIC (8259) 数据输出

    // RAM 控制信号
    output wire          ram_wren,      // RAM 写使能 (高电平有效)
    output wire [13:0]   ram_addr,      // RAM 地址 (16KB -> 14位)
    output wire [7:0]    ram_data,      // 写给 RAM 的数据

    // ROM 控制信号
    output wire [13:0]   rom_addr,      // ROM 地址 (16KB -> 14位)

    // PIC (8259) 控制信号
    output wire          pic_cs_n,      // PIC 片选 (低电平有效)
    output wire          pic_a0,        // PIC 寄存器选择 (地址位0)
    output wire [7:0]    pic_din,       // 写给 PIC 的数据
    output wire          pic_inta_n,    // 中断响应信号 (给 PIC)

    // PIT (8254) 控制信号
    output wire         pit_cs_n,
    output wire         pit_a0,
    output wire         pit_a1,
    output wire [7:0]   pit_din,
    input  wire [7:0]   pit_dout,

    // PPI (8255) 控制信号
    output wire         ppi_cs_n,
    output wire [1:0]   ppi_addr,
    output wire [7:0]   ppi_din,
    input  wire [7:0]   ppi_dout,

    // UART (16550) 控制信号
    output wire [7:0]   uart_din,
    input  wire [7:0]   uart_dout,
    output wire [2:0]   uart_addr,
    output wire         uart_cs_n,

    // DMA (8237) 控制信号
    output wire         dma_cs_n,      // DMA 片选 (CPU 访问 DMA 寄存器时使用)
    output wire [3:0]   dma_ain,       // CPU 访问 DMA 时的地址输入
    output wire [7:0]   dma_din,       // 送给 DMA 的数据 (RAM读取数据 或 CPU配置数据)
    input  wire [7:0]   dma_dout,      // DMA 输出的数据 (DMA配置读取 或 内存写数据)

    // DMA 主控信号 (当 DMA 获得总线权时由 DMA 输入)
    input  wire         dma_mrdc_n,
    input  wire         dma_mwtc_n,
    input  wire         dma_iorc_n,
    input  wire         dma_iowc_n,
    input  wire         dma_aen,       // DMA 地址允许 (1=DMA主控, 0=CPU主控) -> 关键仲裁信号
    input  wire         dma_dben,
    input  wire         dma_adstb,
    input  wire [3:0]   dma_dack,      // DMA 响应信号 (用于选择外设)
    input  wire [7:0]   dma_aout       // DMA 输出的高位地址 (配合外部锁存器)
);

    // 总线仲裁逻辑 (Bus Arbitration)

    // 内部地址总线：根据 AEN 选择 CPU 地址还是 DMA 地址
    wire [19:0] sys_addr;
    wire [19:0] dma_addr;
    assign sys_addr = (dma_aen) ? dma_addr : cpu_addr;

    // CPU 侧产生的控制信号 (预处理)
    wire cpu_mrdc_n_int, cpu_mwtc_n_int, cpu_iorc_n_int, cpu_iowc_n_int;

    assign cpu_mrdc_n_int = (cpu_iom == 1'b0 && cpu_rd_n == 1'b0) ? 1'b0 : 1'b1;
    assign cpu_mwtc_n_int = (cpu_iom == 1'b0 && cpu_wr_n == 1'b0) ? 1'b0 : 1'b1;
    assign cpu_iorc_n_int = (cpu_iom == 1'b1 && cpu_rd_n == 1'b0) ? 1'b0 : 1'b1;
    assign cpu_iowc_n_int = (cpu_iom == 1'b1 && cpu_wr_n == 1'b0) ? 1'b0 : 1'b1;

    // 最终系统控制信号：根据 AEN 选择 CPU 信号还是 DMA 信号
    assign mrdc_n = (dma_aen) ? dma_mrdc_n : cpu_mrdc_n_int;
    assign mwtc_n = (dma_aen) ? dma_mwtc_n : cpu_mwtc_n_int;
    assign iorc_n = (dma_aen) ? dma_iorc_n : cpu_iorc_n_int;
    assign iowc_n = (dma_aen) ? dma_iowc_n : cpu_iowc_n_int;

    // 地址译码逻辑 (Address Decoding)

    // 内部片选信号 (高电平表示选中)
    wire ram_cs, rom_cs, pic_cs, pit_cs, ppi_cs, uart_cs, dma_cs;

    // RAM: 0x00000 - 0x03FFF
    // 选中条件：A19..A14 = 000000，且必须是存储器操作 (dma_aen=1 时默认为存储器传输或由 dma_dack 区分)
    // 这里简化处理：只要地址匹配即选中
    assign ram_cs = (sys_addr[19:14] == 6'b000000) ? 1'b1 : 1'b0;

    // ROM: 0xFC000 - 0xFFFFF
    assign rom_cs = (sys_addr[19:14] == 6'b111111) ? 1'b1 : 1'b0;

    // IO 空间译码 (注意：DMA 模式下地址可能无效，主要靠 DACK，但这里保留地址映射供 CPU 访问) ---

    // DMA (8237): IO Space, Address 0x00 - 0x0F (标准 PC 映射)
    // 只有在 CPU 控制总线时 (dma_aen=0) 且地址匹配时选中
    assign dma_cs = (!dma_aen && sys_addr[7:4] == 4'b0000) ? 1'b1 : 1'b0;

    // PIC (8259): IO Space, Address 0x20 - 0x21
    assign pic_cs = (!dma_aen && sys_addr[7:4] == 4'b0010) ? 1'b1 : 1'b0;

    // PIT (8254): IO Space, Address 0x40 - 0x43
    assign pit_cs = (!dma_aen && sys_addr[7:4] == 4'b0100) ? 1'b1 : 1'b0;

    // PPI (8255): IO Space, Address 0x60 - 0x63
    assign ppi_cs = (!dma_aen && sys_addr[7:4] == 4'b0110) ? 1'b1 : 1'b0;

    // UART (16550): IO Space, Address 0x3F8 - 0x3FF
    assign uart_cs = (!dma_aen && sys_addr[9:3] == 7'b1111111) ? 1'b1 : 1'b0;

    // 输出信号分配 (Output Assignments)

    // --- RAM 接口 ---
    assign ram_addr = sys_addr[13:0]; // 使用仲裁后的地址
    assign ram_data = (dma_aen) ? dma_dout : cpu_dout;
    assign ram_wren = (ram_cs == 1'b1 && mwtc_n == 1'b0) ? 1'b1 : 1'b0;

    // --- ROM 接口 ---
    assign rom_addr = sys_addr[13:0];

    // --- PIC (8259) 接口 ---
    assign pic_cs_n   = !pic_cs;
    assign pic_a0     = sys_addr[0];
    assign pic_din    = cpu_dout;    // PIC 只能被 CPU 配置
    assign pic_inta_n = cpu_inta_n;

    // --- PIT (8254) 接口 ---
    assign pit_cs_n = ~pit_cs;
    assign pit_a0   = sys_addr[0];
    assign pit_a1   = sys_addr[1];
    assign pit_din  = cpu_dout;

    // --- PPI (8255) 接口 ---
    assign ppi_cs_n = ~ppi_cs;
    assign ppi_addr = sys_addr[1:0];
    assign ppi_din  = cpu_dout;

    // --- UART (16550) 接口 ---
    assign uart_cs_n = ~uart_cs;
    assign uart_addr = sys_addr[2:0];
    assign uart_din  = cpu_dout;

    // --- DMA (8237) Slave 接口 (CPU 读写 DMA 寄存器) ---
    assign dma_cs_n = ~dma_cs;
    assign dma_ain  = sys_addr[3:0]; // DMA 内部通常有16个寄存器地址空间
    // dma_din 的数据来源：
    // 1. 当 CPU 写 DMA 寄存器时 (dma_aen=0, dma_cs=1)，数据来自 cpu_dout。
    // 2. 当 DMA 读 存储器时 (dma_aen=1, Mem -> IO)，数据来自 ram_q/rom_q。
    assign dma_din  = (dma_aen) ? ram_q : cpu_dout;

    // 数据总线多路复用 (Data Bus Multiplexer to CPU)

    // cpu_din: CPU 读取到的数据
    // 注意：增加了读取 DMA 寄存器的情况 (dma_cs)
    assign cpu_din = (!cpu_inta_n) ? pic_dout :
                     (ram_cs && !mrdc_n) ? ram_q :       // 读 RAM
                     (rom_cs && !mrdc_n) ? rom_q :       // 读 ROM
                     (pic_cs && !iorc_n) ? pic_dout :    // 读 PIC
                     (pit_cs && !iorc_n) ? pit_dout :    // 读 PIT
                     (ppi_cs && !iorc_n) ? ppi_dout :    // 读 PPI
                     (uart_cs && !iorc_n) ? uart_dout :  // 读 UART
                     (dma_cs && !iorc_n)  ? dma_dout :   // 读 DMA 寄存器
                     8'h00;

endmodule
