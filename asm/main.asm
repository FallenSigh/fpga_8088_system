.model tiny
        .code
        .8086

        ; --- 内存/端口定义 ---
        ROM_SEGMENT     EQU     0FC00h

        ; --- RAM 变量定义 (DS=0000h) ---
        VAR_TICKS       EQU     0500h   ; [Word] 1ms 计数器
        VAR_SCAN_IDX    EQU     0502h   ; [Byte] 扫描索引
        VAR_DIGITS      EQU     0510h   ; [Bytes] 显存数组 (6字节, 0510=个位 ... 0515=十万位)

        VAR_LED_TIMER   EQU     0520h   ; [Word] LED 计时
        VAR_LED_STATE   EQU     0522h   ; [Byte] LED 状态

        VAR_SEND_REQ    EQU     0530h   ; [Byte] 串口发送请求标志 (1=需要发送, 0=空闲)

        ; --- 硬件端口 ---
        ; 8259 PIC
        PIC_ICW1        EQU     20H
        PIC_ICW2        EQU     21H
        PIC_ICW4        EQU     21H

        ; 8254 PIT
        PIT_CNT0        EQU     40H
        PIT_CTRL        EQU     43H

        ; 8255 PPI
        PPI_PORTA       EQU     60H
        PPI_PORTB       EQU     61H
        PPI_PORTC       EQU     62H
        PPI_CTRL        EQU     63H

        ; 16550 UART (COM1)
        COM1_BASE       EQU     3F8H
        COM1_RBR        EQU     3F8H    ; Read Buffer
        COM1_THR        EQU     3F8H    ; Transmit Holding
        COM1_DLL        EQU     3F8H    ; Divisor Low (DLAB=1)
        COM1_DLM        EQU     3F9H    ; Divisor High (DLAB=1)
        COM1_IER        EQU     3F9H    ; Interrupt Enable
        COM1_LCR        EQU     3FBH    ; Line Control
        COM1_LSR        EQU     3FDH    ; Line Status

        org     0h

; --- ROM 表格 ---
SegTab  db 0C0h,0F9h,0A4h,0B0h,099h,092h,082h,0F8h,080h,090h
BitTab  db 01h, 02h, 04h, 08h, 10h, 20h

; 中断服务程序 (每 1ms 触发)
IR0_ISR PROC FAR
        PUSH AX
        PUSH BX
        PUSH CX
        PUSH SI
        PUSH DS

        MOV  AX, 0000h
        MOV  DS, AX

        ; 秒计数逻辑
        MOV  BX, VAR_TICKS
        MOV  AX, [BX]
        INC  AX
        MOV  [BX], AX

        CMP  AX, 1000
        JB   TASK_LED

        ; 秒脉冲处理
        MOV  WORD PTR [BX], 0   ; 清零毫秒VAR_TICKS

        ; 设置串口发送请求标志 (通知主循环)
        MOV  BX, VAR_SEND_REQ
        MOV  BYTE PTR [BX], 1

        ; 6位 BCD 进位加法
        MOV  SI, VAR_DIGITS
        MOV  CX, 6
INC_LOOP:
        MOV  AL, [SI]
        INC  AL
        CMP  AL, 10
        JB   NO_CARRY
        MOV  BYTE PTR [SI], 0
        INC  SI
        LOOP INC_LOOP
        JMP  TASK_LED
NO_CARRY:
        MOV  [SI], AL

        ; LED 流水灯逻辑
TASK_LED:
        MOV  BX, VAR_LED_TIMER
        MOV  AX, [BX]
        INC  AX
        MOV  [BX], AX

        CMP  AX, 200            ; 200ms 速度
        JB   TASK_SCAN

        MOV  WORD PTR [BX], 0
        MOV  BX, VAR_LED_STATE
        MOV  AL, [BX]
        SHL  AL, 1
        TEST AL, 10h            ; 检查是否溢出低4位
        JZ   UPDATE_LED
        MOV  AL, 01h
UPDATE_LED:
        MOV  [BX], AL
        NOT  AL
        MOV  DX, PPI_PORTC
        OUT  DX, AL

        ; 数码管扫描
TASK_SCAN:
        MOV  DX, PPI_PORTB
        MOV  AL, 00h
        OUT  DX, AL             ; 消隐

        MOV  BX, VAR_SCAN_IDX
        MOV  AL, [BX]
        XOR  AH, AH
        MOV  SI, AX

        INC  AL
        CMP  AL, 6
        JB   SAVE_IDX
        MOV  AL, 0
SAVE_IDX:
        MOV  [BX], AL

        MOV  BX, OFFSET BitTab
        MOV  CL, CS:[BX + SI]   ; 查位选

        MOV  BX, VAR_DIGITS
        MOV  AL, [BX + SI]
        XOR  AH, AH
        MOV  SI, AX
        MOV  BX, OFFSET SegTab
        MOV  AL, CS:[BX + SI]   ; 查段码

        MOV  DX, PPI_PORTA
        OUT  DX, AL
        MOV  DX, PPI_PORTB
        MOV  AL, CL
        OUT  DX, AL

        MOV  AL, 20H            ; EOI
        OUT  20H, AL

        POP  DS
        POP  SI
        POP  CX
        POP  BX
        POP  AX
        IRET
IR0_ISR ENDP

; 串口发送子程序 (辅助函数)
; 输入: AL = 要发送的字节
UART_SendByte PROC NEAR
        PUSH DX
        PUSH AX

        MOV  DX, COM1_THR
        OUT  DX, AL             ; 写入发送寄存器

WAIT_TX:
        ; 等待发送完毕 (查询 LSR Bit 5: THRE)
        MOV  DX, COM1_LSR
        IN   AL, DX
        AND  AL, 20h            ; 0010 0000
        JZ   WAIT_TX            ; 如果为0，继续等待

        POP  AX
        POP  DX
        RET
UART_SendByte ENDP

; 主程序
start:
        cli
        mov     ax, 0000h
        mov     ds, ax
        mov     es, ax
        mov     ss, ax
        mov     sp, 04000h

        ; 变量初始化
        mov     bx, VAR_TICKS
        mov     word ptr [bx], 0
        mov     bx, VAR_LED_TIMER
        mov     word ptr [bx], 0
        mov     bx, VAR_LED_STATE
        mov     byte ptr [bx], 01h
        mov     bx, VAR_SEND_REQ
        mov     byte ptr [bx], 0   ; 初始不发送

        ; 清显存
        mov     cx, 6
        mov     di, VAR_DIGITS
        xor     ax, ax
CLR_RAM:
        mov     [di], al
        inc     di
        loop    CLR_RAM

        ; 硬件初始化
        ; 8259A
        MOV AL, 13H
        OUT PIC_ICW1, AL
        MOV AL, 20H
        OUT PIC_ICW2, AL
        MOV AL, 09H
        OUT PIC_ICW4, AL

        ; 中断向量
        MOV BX, 80H
        MOV AX, OFFSET IR0_ISR
        MOV WORD PTR [BX], AX
        MOV BX, 82H
        MOV AX, ROM_SEGMENT
        MOV WORD PTR [BX], AX

        ; 8254
        mov dx, PIT_CTRL
        mov al, 36h
        out dx, al
        mov dx, PIT_CNT0
        mov al, 0E8h
        out dx, al
        mov al, 03h
        out dx, al

        ; 4. 8255
        mov dx, PPI_CTRL
        mov al, 80h
        out dx, al

        ; 16550 UART 初始化 (115200, 8N1)
        ; 设置 DLAB=1 访问除数锁存器
        mov dx, COM1_LCR
        mov al, 80h
        out dx, al

        ; 设置波特率 115200 (50MHz / 16 / 27)
        mov dx, COM1_DLL
        mov al, 1Bh
        out dx, al
        mov dx, COM1_DLM
        mov al, 00h
        out dx, al

        ; 设置 DLAB=0, 8数据位, 1停止位, 无校验
        mov dx, COM1_LCR
        mov al, 03h         ; 0000 0011
        out dx, al

        sti

        ; 主循环
forever:
        ; 检查是否有发送请求
        mov bx, VAR_SEND_REQ
        mov al, [bx]
        test al, al
        jz  forever             ; 如果是0，继续空转

        ; --- 开始发送数据 ---
        mov byte ptr [bx], 0    ; 清除标志位，避免重复发送

        ; 发送换行符 (CR LF) 让显示整齐
        mov al, 0Dh
        call UART_SendByte
        mov al, 0Ah
        call UART_SendByte

        ; 倒序发送 6 位数字 (从高位到低位: 0515h -> 0510h)
        mov si, 5
SEND_LOOP:
        mov bx, VAR_DIGITS
        mov al, [bx + si]       ; 读取数字 (0-9)
        add al, 30h             ; 转换为 ASCII ('0'-'9')
        call UART_SendByte

        dec si
        jns SEND_LOOP           ; 如果 si >= 0 继续

        jmp forever

; Reset Vector
        org     03ff0h
        db      0EAh
        dw      offset start
        dw      ROM_SEGMENT
        org     03fffh
        db      0

        end
