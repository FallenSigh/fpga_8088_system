.model tiny
        .code
        .8086

        ROM_SEGMENT EQU 0FC00h
        PIC_ICW1        EQU     20H
        PIC_ICW2        EQU     21H
        PIC_ICW3        EQU     21H
        PIC_ICW4        EQU     21H
        ; ROM: 0xFC000-0xFFFFF
        ; RAM: 0x00000-0x03FFF
        org     0h

IR0_ISR PROC FAR
        PUSH AX
        PUSH DX

        MOV AL, 01H
        OUT  56H, AL

        ; ===============================
        ; 2. 发送 EOI（必须）
        ; ===============================
        MOV  AL, 20H             ; Non-specific EOI
        OUT  20H, AL             ; 写 8259 命令端口

        ; ===============================
        ; 3. 恢复现场并返回
        ; ===============================
        POP  DX
        POP  AX
        IRET
    IR0_ISR ENDP

start:
        cli                     ; 初始化期间关闭中断

        mov     ax, 0000h
        mov     ds, ax
        mov     es, ax
        mov     ss, ax

        mov     sp, 04000h      ; SP 指向 0x0000:0x4000 (RAM 顶端)

        ; 1. 初始化 8259A (ICW1)
        ; D4=1: 需要ICW4
        ; D1=0: 单片 (Single PIC) 模式
        ; D0=1: 边缘触发 (Edge-triggered) 模式
        MOV AL, 13H         ; ICW1: 00010011B
        MOV DX, PIC_ICW1
        OUT DX, AL         ; 发送给 8259A 的命令端口 (20H)

        ; 2. 设置 8259A 的中断向量基地址 (ICW2)
        ; T7-T3: 中断向量号的高5位。这里设置为 20H (32)
        MOV AL, 20H         ; 中断向量起始地址 20H
        OUT PIC_ICW2, AL         ; 发送给 8259A 的数据端口 (21H)

        ; 3. 配置 8259A 的级联信息 (ICW3)
        ; 在单片模式下，ICW3 无效，但通常为了完整性，会发送一个零值。
        ; 有些系统设计可能允许跳过此步，但为了兼容性，保留它。
        MOV AL, 09H         ; ICW3: 在单片模式下，该值无关紧要
        OUT PIC_ICW3, AL         ; 发送给 8259A 的数据端口

        ; 安装中断向量
        ; 1. 设置偏移地址 (Offset)
        MOV BX, 80H
        MOV AX, OFFSET IR0_ISR ; 获取 IR0_ISR 的偏移地址
        MOV WORD PTR [BX], AX
        ; 2. 设置段地址 (Segment)
        MOV BX, 82H
        MOV AX, ROM_SEGMENT ; 设置段地址 FC00H
        MOV WORD PTR [BX], AX

        STI                         ; 开中断

stop_here:
        jmp     stop_here

        ; --- GW8088 BOOT CODE (Reset Vector) ---
        org     03ff0h

        db      0EAh
        dw      offset start
        dw      ROM_SEGMENT

        org     03fffh
        db      0

        end
