.model tiny
        .code
        .8086

        ROM_SEGMENT EQU 0FC00h
        ; ROM: 0xFC000-0xFFFFF
        ; RAM: 0x00000-0x03FFF
        org     0h

IR0_ISR PROC FAR
        PUSH AX
        PUSH DX

        MOV AL, 01H
        OUT  80H, AL

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

        mov bx, 100
        push bx
        mov bx, 300
        push bx
        push bx
        pop bx

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
