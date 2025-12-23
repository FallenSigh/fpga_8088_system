# MPE - 8088微处理器FPGA系统

![FPGA](https://img.shields.io/badge/FPGA-Cyclone%20IV%20E-blue)
![Quartus](https://img.shields.io/badge/Quartus-22.1std.2-green)
![8088](https://img.shields.io/badge/CPU-8088-red)
![Status](https://img.shields.io/badge/Status-已完成上板测试-success)

一个完整的8088微处理器系统在FPGA上的实现，集成了多种经典外设芯片，实现了x86兼容的计算机系统。

## 📋 项目简介

MPE（MicroProcessor Experiment）是一个基于Intel Cyclone IV E FPGA的8088微处理器系统项目。该项目完整实现了8088 CPU核心、系统总线、存储器以及多种经典外设，提供了一个完整的x86兼容计算机系统平台。

**项目目标：**
- 在FPGA上实现完整的8088微处理器系统
- 集成8259、8254、8255等经典外设芯片
- 提供软硬件协同开发环境
- 支持教学和实验用途

## ✨ 特性

### 🖥️ 硬件特性
- **处理器核心**：完整的8088微处理器实现
- **存储系统**：16KB RAM + 16KB ROM
- **系统总线**：支持CPU/DMA仲裁的20位地址总线
- **时钟系统**：50MHz主时钟，PLL分频生成多路时钟
- **外设集成**：
  - 8259 可编程中断控制器 (PIC)
  - 8254 可编程间隔定时器 (PIT)
  - 8255 可编程并行接口 (PPI)
  - 8237 DMA控制器
  - 16550 UART串口控制器
  - 74HC595 LED/数码管显示控制

### 💾 软件特性
- **汇编支持**：完整的8088汇编程序开发环境
- **中断系统**：完整的中断向量表和中断处理
- **外设驱动**：所有外设的初始化和管理程序
- **调试支持**：串口调试输出和状态显示

## 🏗️ 系统架构

### 地址空间映射
```
内存空间 (1MB):
  0x00000 - 0x03FFF: RAM (16KB)
  0xFC000 - 0xFFFFF: ROM (16KB)

IO空间 (标准PC映射):
  0x00 - 0x0F: DMA控制器 (8237)
  0x20 - 0x21: 中断控制器 (8259)
  0x40 - 0x43: 定时器 (8254)
  0x60 - 0x63: 并行接口 (8255)
  0x3F8 - 0x3FF: 串口控制器 (16550)
```

### 总线架构
- **20位地址总线**，支持1MB寻址空间
- **8位数据总线**
- **总线仲裁**：支持CPU和DMA之间的动态总线切换
- **地址译码**：完整的存储器映射和IO映射

## 🚀 快速开始

### 环境要求
- **FPGA开发工具**：Intel Quartus Prime 22.1std.2或更高版本
- **汇编工具**：MASM汇编器 (Microsoft Macro Assembler)
- **Python 3**：用于二进制文件转换
- **硬件平台**：Cyclone IV E EP4CE10F17C8开发板

### 构建步骤

#### 1. 汇编程序构建
```bash
# 进入汇编目录
cd asm/

# 编译汇编程序
build.bat main

# 构建过程：
# 1. 汇编 main.asm → main.obj
# 2. 链接 main.obj → main.exe
# 3. 转换 main.exe → rom.hex (16KB Intel HEX格式)
# 4. 清理临时文件
```

#### 2. FPGA项目编译
1. 打开Quartus Prime
2. 打开项目文件：`quartus_project/mpe.qsf`
3. 执行完整编译流程：
   - Analysis & Synthesis
   - Fitter (Place & Route)
   - Assembler (生成编程文件)
   - Timing Analysis
4. 生成编程文件：`quartus_project/output_files/mpe.sof`

#### 3. 下载到FPGA
1. 使用USB-Blaster或其他编程器
2. 将`mpe.sof`文件下载到FPGA
3. 系统自动启动运行

## 📁 目录结构

```
MPE/
├── asm/                    # 8088汇编程序
│   ├── main.asm           # 主汇编程序
│   ├── build.bat          # 汇编构建脚本 (Windows)
│   ├── exe2hex.py         # EXE转HEX转换脚本
│   ├── rom.hex            # 生成的ROM镜像
│   └── MASM.EXE           # MASM汇编器 (需自行准备)
├── quartus_project/        # Quartus FPGA项目
│   ├── top.bdf            # 顶层Block Diagram设计
│   ├── mpe.qsf            # Quartus项目设置文件
│   ├── pin.tcl            # FPGA引脚分配文件
│   ├── mpe_assignment_defaults.qdf  # 默认设置
│   ├── *.bsf              # 各种Block Symbol文件
│   └── output_files/      # 编译输出文件 (生成)
├── rtl/                    # Verilog RTL源代码
│   ├── mpe.v              # 主系统模块 (顶层)
│   ├── system_bus.v       # 系统总线控制器
│   ├── hc595_ctrl.v       # 74HC595移位寄存器控制
│   ├── uart_clk.v         # UART时钟生成模块
│   ├── pll/               # PLL时钟模块
│   ├── ram/               # RAM存储器模块
│   ├── rom/               # ROM存储器模块
│   └── gw*.vqm            # 各种外设IP核文件
├── testbench/             # 测试文件
│   └── tb_top.v           # 顶层测试文件
├── .spec-workflow/        # 项目规范工作流模板
├── .gitignore            # Git忽略文件
├── CLAUDE.md             # Claude Code助手文档
└── README.md             # 项目说明文档 (本文件)
```

## 🔧 硬件规格

### FPGA器件
- **型号**：Intel Cyclone IV E EP4CE10F17C8
- **逻辑单元**：10,320 LE
- **存储器**：414 Kbits
- **封装**：256-pin FineLine BGA

### 引脚分配
| 信号 | 引脚 | 说明 |
|------|------|------|
| `clk` | PIN_E1 | 系统时钟输入 (50MHz) |
| `rst_n` | PIN_M15 | 系统复位 (低电平有效) |
| `led[3:0]` | PIN_L7, M6, P3, N3 | LED状态指示灯 |
| `uart_tx` | PIN_N5 | 串口发送 |
| `uart_rx` | PIN_N6 | 串口接收 |
| `stcp` | PIN_K9 | 74HC595存储寄存器时钟 |
| `shcp` | PIN_B1 | 74HC595移位寄存器时钟 |
| `ds` | PIN_R1 | 74HC595串行数据输入 |
| `oe` | PIN_L11 | 74HC595输出使能 |

### 时钟系统
- **主时钟**：50MHz 外部晶振
- **系统时钟**：25MHz (PLL分频)
- **UART时钟**：1.8432MHz (标准波特率时钟)
- **定时器时钟**：1MHz (8254定时器时钟)

## 💻 软件开发

### 汇编程序开发
汇编程序位于`asm/main.asm`，包含以下功能：

1. **系统初始化**
   ```assembly
   ; 初始化8259中断控制器
   mov al, 0x13        ; ICW1: 边沿触发，单片8259
   out 0x20, al
   mov al, 0x08        ; ICW2: 中断向量基址0x08
   out 0x21, al
   mov al, 0x01        ; ICW4: 8086模式
   out 0x21, al
   ```

2. **外设初始化**
   - 8254定时器配置
   - 8255并行接口配置
   - 16550串口配置

3. **应用程序**
   - LED控制程序
   - 数码管显示程序
   - 串口通信程序
   - 中断处理程序

### 构建脚本
`asm/build.bat` 自动化构建脚本：
```batch
@echo off
if "%1"=="" (
    echo Usage: build.bat <basename>
    echo Example: build.bat main
    exit /b 1
)

set NAME=%1
ml /c /Fl %NAME%.asm
link %NAME%.obj < nul
python exe2hex.py %NAME%.exe rom.hex
rm %NAME%.exe
rm %NAME%.obj
```

### ROM转换工具
`asm/exe2hex.py` 将EXE文件转换为16KB Intel HEX格式：
- 自动解析DOS MZ头
- 提取代码段数据
- 填充到16KB固定大小
- 生成Intel HEX格式文件

## 🛠️ 硬件开发

### RTL设计
主要RTL模块：

1. **`mpe.v`** - 顶层系统模块
   - 实例化所有子模块
   - 时钟和复位管理
   - 外部接口定义

2. **`system_bus.v`** - 系统总线控制器
   - 地址译码逻辑
   - 总线仲裁逻辑 (CPU/DMA)
   - 数据总线多路复用

3. **`hc595_ctrl.v`** - 74HC595控制
   - 串行转并行数据转换
   - LED和数码管显示控制

### Block Diagram设计
`quartus_project/top.bdf` 提供了图形化的系统设计：
- 8088 CPU核心连接
- 外设芯片互连
- 时钟网络设计
- 复位电路设计

### 引脚约束
`quartus_project/pin.tcl` 定义所有FPGA引脚分配：
```tcl
set_location_assignment PIN_E1 -to clk
set_location_assignment PIN_M15 -to rst_n
set_location_assignment PIN_L7 -to led[0]
# ... 更多引脚定义
```

## 🧪 测试验证

### 仿真测试
使用`testbench/tb_top.v`进行功能仿真：
```verilog
module tb_top;
    // 时钟和复位生成
    reg clk = 0;
    reg rst_n = 0;

    // 实例化被测系统
    mpe uut (
        .clk(clk),
        .rst_n(rst_n),
        // ... 其他信号连接
    );

    // 测试激励
    initial begin
        // 复位序列
        #100 rst_n = 1;

        // 运行测试
        #10000 $finish;
    end

    // 时钟生成
    always #10 clk = ~clk; // 50MHz时钟
endmodule
```

### 上板测试
1. **基本功能测试**
   - 系统启动和复位
   - LED指示灯测试
   - 串口通信测试

2. **外设功能测试**
   - 8259中断测试
   - 8254定时器测试
   - 8255并行接口测试
   - 16550串口测试

3. **性能测试**
   - 时钟频率验证
   - 存储器访问测试
   - 中断响应时间测试

## ❓ 常见问题

### Q1: 系统无法启动
**可能原因：**
- 时钟信号异常
- 复位信号未正确释放
- FPGA配置失败

**解决方案：**
1. 检查时钟源和时钟引脚连接
2. 验证复位电路和复位信号
3. 重新下载FPGA配置文件

### Q2: 外设不工作
**可能原因：**
- 片选信号未正确生成
- 初始化序列错误
- 地址映射不匹配

**解决方案：**
1. 检查`system_bus.v`中的地址译码逻辑
2. 验证汇编程序中的外设初始化代码
3. 使用逻辑分析仪检查控制信号

### Q3: 中断不触发
**可能原因：**
- 8259配置错误
- 中断屏蔽位设置
- 中断向量表错误

**解决方案：**
1. 检查8259初始化序列
2. 验证中断屏蔽寄存器设置
3. 确认中断向量表位置和内容

### Q4: ROM程序超过16KB限制
**可能原因：**
- 汇编程序代码过大
- 数据段占用过多空间

**解决方案：**
1. 优化代码，移除不必要的功能
2. 使用代码压缩技术
3. 考虑扩展ROM容量

## 🤝 贡献指南

欢迎贡献代码和文档！请遵循以下步骤：

1. **Fork项目**
2. **创建功能分支**
   ```bash
   git checkout -b feature/新功能
   ```
3. **提交更改**
   ```bash
   git commit -m "添加: 新功能描述"
   ```
4. **推送到分支**
   ```bash
   git push origin feature/新功能
   ```
5. **创建Pull Request**

### 代码规范
- Verilog代码遵循IEEE 1364标准
- 汇编代码使用MASM语法
- 注释使用中文或英文，保持清晰
- 模块接口文档完整

### 文档规范
- 使用Markdown格式
- 包含必要的代码示例
- 更新相关文档和注释

## 📄 许可证

本项目采用MIT许可证。详见LICENSE文件。

## 📞 联系与支持

如有问题或建议，请通过以下方式联系：

- **问题反馈**：在GitHub Issues中提交问题
- **功能请求**：创建Feature Request Issue
- **文档改进**：提交Pull Request更新文档

## 📊 项目状态

- **当前版本**：v1.0
- **最后更新**：2025年12月
- **FPGA编译**：已完成
- **上板测试**：已完成
- **文档状态**：完善中

---

**致谢**：感谢所有为项目做出贡献的开发者和测试人员！

**注意**：本项目主要用于教学和实验目的，部分功能可能仍在开发中。