.model tiny
        .code
        .8086

        ROM_SEGMENT EQU 0FC00h 
        
        org     0h

start:        
        cli                     ; 初始化期间关闭中断

        mov     ax, 0000h       
        mov     ds, ax
        mov     es, ax
        mov     ss, ax

        mov     sp, 04000h      ; SP 指向 0x0000:0x4000 (RAM 顶端)
        
        mov bx, 1234h
        mov cx, 1369h
        add cx, bx
        
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