.model tiny
.code
.8086

; --- 内存/端口定义 ---
ROM_SEGMENT     EQU     0FC00h

; --- RAM 变量定义 ---
VAR_TICKS       EQU     0500h   ; [Word] 1ms 计数器
VAR_SCAN_IDX    EQU     0502h   ; [Byte] 扫描索引
VAR_DIGITS      EQU     0510h   ; [Bytes] 显存数组 (6字节)
VAR_LED_TIMER   EQU     0520h   ; [Word] LED 计时
VAR_LED_STATE   EQU     0522h   ; [Byte] LED 状态
VAR_SEND_REQ    EQU     0530h   ; [Byte] 串口发送请求标志

; --- 标志位定义 (VAR_FLAGS) ---
; Bit 0: 1=暂停, 0=运行
; Bit 1: 1=倒计时, 0=正计时
; Bit 2: 1=10倍速, 0=正常速度
VAR_FLAGS       EQU     0531h

; --- 硬件端口 ---
; 8259 PIC
PIC_ICW1        EQU     20H
PIC_ICW2        EQU     21H
PIC_ICW4        EQU     21H
PIC_OCW1        EQU     21H

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
COM1_RBR        EQU     3F8H
COM1_THR        EQU     3F8H
COM1_LSR        EQU     3FDH
COM1_DLL        EQU     3F8H
COM1_DLM        EQU     3F9H
COM1_LCR        EQU     3FBH

org     0h

; --- ROM 表格 ---
SegTab  db 0C0h,0F9h,0A4h,0B0h,099h,092h,082h,0F8h,080h,090h
BitTab  db 01h, 02h, 04h, 08h, 10h, 20h

; ============================================
; IR0 中断服务程序 (Timer - 1ms)
; 功能：扫描数码管、计时、LED流水灯
; ============================================
IR0_ISR PROC FAR
        PUSH AX
        PUSH BX
        PUSH CX
        PUSH DX
        PUSH SI
        PUSH DS

        MOV  AX, 0000h
        MOV  DS, AX

        ; --- 1. 检查暂停 (Bit 0) ---
        MOV  BX, VAR_FLAGS
        MOV  DL, [BX]           ; DL 保存 Flags 副本
        TEST DL, 01h
        JNZ  SKIP_COUNTING      ; 暂停则跳过

        ; --- 2. 毫秒计数与速度控制 ---
        MOV  BX, VAR_TICKS
        MOV  AX, [BX]
        INC  AX
        MOV  [BX], AX

        ; 检查速度 (Bit 2)
        MOV  CX, 1000           ; 默认阈值 1000ms = 1s
        TEST DL, 04h            ; Check Bit 2
        JZ   CHECK_THRESHOLD
        MOV  CX, 100            ; 加速模式：100ms 就进位 (10倍速)

CHECK_THRESHOLD:
        CMP  AX, CX
        JB   TASK_LED           ; 没满1秒，去处理LED

        ; --- 3. 秒脉冲处理 ---
        MOV  WORD PTR [BX], 0   ; 清零毫秒计数
        MOV  BX, VAR_SEND_REQ
        MOV  BYTE PTR [BX], 1   ; 请求串口发送

        ; --- 4. 计数逻辑 (加法/减法) ---
        MOV  SI, VAR_DIGITS
        MOV  CX, 6

        TEST DL, 02h            ; Check Bit 1 (Direction)
        JNZ  DO_DECREMENT       ; 1 = 倒计时

        ; [正计时逻辑]
INC_LOOP:
        MOV  AL, [SI]
        INC  AL
        CMP  AL, 10
        JB   UPDATE_DIGIT
        MOV  BYTE PTR [SI], 0
        INC  SI
        LOOP INC_LOOP
        JMP  TASK_LED

        ; [倒计时逻辑]
DO_DECREMENT:
        MOV  AL, [SI]
        DEC  AL
        JNS  UPDATE_DIGIT       ; 如果 >=0 (没有借位)
        MOV  BYTE PTR [SI], 9   ; 变成9
        INC  SI                 ; 处理高一位
        LOOP DO_DECREMENT
        JMP  TASK_LED

UPDATE_DIGIT:
        MOV  [SI], AL

TASK_LED:
        ; --- LED 流水灯 ---
        MOV  BX, VAR_LED_TIMER
        MOV  AX, [BX]
        INC  AX
        MOV  [BX], AX
        CMP  AX, 200
        JB   TASK_SCAN

        MOV  WORD PTR [BX], 0
        MOV  BX, VAR_LED_STATE
        MOV  AL, [BX]
        SHL  AL, 1
        TEST AL, 10h
        JZ   WRITE_LED
        MOV  AL, 01h
WRITE_LED:
        MOV  [BX], AL
        NOT  AL
        MOV  DX, PPI_PORTC
        OUT  DX, AL

        JMP  TASK_SCAN

SKIP_COUNTING:
        NOP

TASK_SCAN:
        ; --- 数码管扫描 ---
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
        MOV  CL, CS:[BX + SI]   ; 位码
        MOV  BX, VAR_DIGITS
        MOV  AL, [BX + SI]
        XOR  AH, AH
        MOV  SI, AX
        MOV  BX, OFFSET SegTab
        MOV  AL, CS:[BX + SI]   ; 段码

        MOV  DX, PPI_PORTA
        OUT  DX, AL
        MOV  DX, PPI_PORTB
        MOV  AL, CL
        OUT  DX, AL

        MOV  AL, 20H
        OUT  20H, AL            ; EOI

        POP  DS
        POP  SI
        POP  DX
        POP  CX
        POP  BX
        POP  AX
        IRET
IR0_ISR ENDP

; ============================================
; IR1 中断服务程序 (Keys - 共用中断)
; 功能：读取 Port C，判断是哪个键按下了
; ============================================
IR1_ISR PROC FAR
        PUSH AX
        PUSH BX
        PUSH CX
        PUSH DX
        PUSH DI
        PUSH DS

        MOV AX, 0000h
        MOV DS, AX

        ; 读取按键状态 (Port C)
        MOV DX, PPI_PORTC
        IN  AL, DX
        ; 假设低电平有效，取反方便判断 (按下变为1)
        NOT AL

        ; AL 现在位定义:
        ; Bit 7=Key3(Reset), Bit 6=Key2(Speed), Bit 5=Key1(Dir), Bit 4=Key0(Pause)

        ; --- 检查 Key3: 复位 ---
        TEST AL, 80h
        JZ   CHK_KEY2
        CALL FUNC_RESET_VARS    ; 调用复位函数
        JMP  IR1_EXIT           ; 复位优先级最高，直接退出

CHK_KEY2:
        ; --- 检查 Key2: 速度切换 ---
        TEST AL, 40h
        JZ   CHK_KEY1
        MOV  BX, VAR_FLAGS
        XOR  BYTE PTR [BX], 04h ; 翻转 Bit 2
        JMP  IR1_EXIT

CHK_KEY1:
        ; --- 检查 Key1: 方向切换 ---
        TEST AL, 20h
        JZ   CHK_KEY0
        MOV  BX, VAR_FLAGS
        XOR  BYTE PTR [BX], 02h ; 翻转 Bit 1
        JMP  IR1_EXIT

CHK_KEY0:
        ; --- 检查 Key0: 暂停/开始 ---
        TEST AL, 10h
        JZ   IR1_EXIT
        MOV  BX, VAR_FLAGS
        XOR  BYTE PTR [BX], 01h ; 翻转 Bit 0

IR1_EXIT:
        ; 简单的软件延时，防止极短时间内的抖动再次触发
        ; 在模拟器中可能不需要，但加上更保险
        MOV  CX, 0FFFh
DELAY_DB:
        LOOP DELAY_DB

        MOV  AL, 20H
        OUT  20H, AL            ; EOI

        POP  DS
        POP  DI
        POP  DX
        POP  CX
        POP  BX
        POP  AX
        IRET
IR1_ISR ENDP

; --------------------------------------------
; 辅助函数：复位变量
; --------------------------------------------
FUNC_RESET_VARS PROC NEAR
        PUSH CX
        PUSH DI
        PUSH AX

        MOV  CX, 6
        MOV  DI, VAR_DIGITS
        XOR  AX, AX
CLR_LOOP_SUB:
        MOV  [DI], AL
        INC  DI
        LOOP CLR_LOOP_SUB

        ; 也可以选择重置Ticks
        MOV  BX, VAR_TICKS
        MOV  WORD PTR [BX], 0

        POP  AX
        POP  DI
        POP  CX
        RET
FUNC_RESET_VARS ENDP

; 串口发送单字节
UART_SendByte PROC NEAR
        PUSH DX
        PUSH AX
        MOV  DX, COM1_THR
        OUT  DX, AL
WAIT_TX:
        MOV  DX, COM1_LSR
        IN   AL, DX
        AND  AL, 20h
        JZ   WAIT_TX
        POP  AX
        POP  DX
        RET
UART_SendByte ENDP

; ============================================
; 主程序
; ============================================
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
        mov     bx, VAR_FLAGS
        mov     byte ptr [bx], 0    ; 初始: 运行, 正向, 正常速
        mov     bx, VAR_LED_STATE
        mov     byte ptr [bx], 01h

        ; 调用复位函数清空显存
        call    FUNC_RESET_VARS

        ; --- 硬件初始化 ---
        ; PIC
        MOV AL, 13H             ; 边沿触发
        OUT PIC_ICW1, AL
        MOV AL, 20H
        OUT PIC_ICW2, AL
        MOV AL, 01H
        OUT PIC_ICW4, AL
        MOV AL, 0FCh            ; 解除 IR0, IR1 屏蔽
        OUT PIC_OCW1, AL

        ; Vectors
        MOV BX, 80H
        MOV AX, OFFSET IR0_ISR
        MOV WORD PTR [BX], AX
        MOV BX, 82H
        MOV AX, ROM_SEGMENT
        MOV WORD PTR [BX], AX

        MOV BX, 84H
        MOV AX, OFFSET IR1_ISR
        MOV WORD PTR [BX], AX
        MOV BX, 86H
        MOV AX, ROM_SEGMENT
        MOV WORD PTR [BX], AX

        ; PIT
        mov dx, PIT_CTRL
        mov al, 36h
        out dx, al
        mov dx, PIT_CNT0
        mov al, 0E8h
        out dx, al
        mov al, 03h
        out dx, al

        ; PPI (Port C Upper IN, Lower Out)
        ; Port C 高4位为输入(Key), 低4位为输出(LED)
        mov dx, PPI_CTRL
        mov al, 88h             ; 1000 1000b (A:Out, B:Out, C_Upper:In, C_Lower:Out)
        out dx, al

        ; UART
        mov dx, COM1_LCR
        mov al, 80h
        out dx, al
        mov dx, COM1_DLL
        mov al, 1Bh
        out dx, al
        mov dx, COM1_DLM
        mov al, 00h
        out dx, al
        mov dx, COM1_LCR
        mov al, 03h
        out dx, al

        sti

; ============================================
; 主循环 (仅处理串口和PC指令)
; ============================================
forever:
        ; --- 串口接收处理 ---
        mov dx, COM1_LSR
        in  al, dx
        test al, 01h
        jz  CHECK_SEND_REQ      ; 如果没收到数据，检查发送请求

        mov dx, COM1_RBR
        in  al, dx
        ; 简单的串口命令
        cmp al, 'r'
        jne TRY_PAUSE
        call FUNC_RESET_VARS
        jmp CHECK_SEND_REQ
TRY_PAUSE:
        cmp al, 'p'
        jne CHECK_SEND_REQ
        mov bx, VAR_FLAGS
        xor byte ptr [bx], 01h

        ; --- 串口发送处理 ---
CHECK_SEND_REQ:
        mov bx, VAR_SEND_REQ
        mov al, [bx]
        test al, al
        jz  forever

        mov byte ptr [bx], 0    ; 清除请求

        ; 发送换行
        mov al, 0Dh
        call UART_SendByte
        mov al, 0Ah
        call UART_SendByte

        ; 发送6位数字
        mov si, 5
SEND_LOOP:
        mov bx, VAR_DIGITS
        mov al, [bx + si]
        add al, 30h
        call UART_SendByte
        dec si
        jns SEND_LOOP

        jmp forever

; Reset Vector
        org     03ff0h
        db      0EAh
        dw      offset start
        dw      ROM_SEGMENT
        org     03fffh
        db      0

        end
