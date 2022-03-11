.model tiny
.code
.186
org 100h

start:

        jmp     initialize

;------------------------------------------------
;New 1Ch handler:
;       If the is_on variable is equal to 1, 
;       it draws a frame with registers 
;       and compares the value of the stored video memory buffer with the screen, 
;       if it is equal to 0, it does nothing.
;------------------------------------------------
int1Ch_handler  proc    near

        pushf
        call    cs:old_int1Ch

        pusha                   ; saving regs
        push    es ds           ; and regs
        push    cs
        pop     ds

        push    sp bp di si dx cx bx ax         ; preparing for showregs


        mov     al, is_on       ; if (false) -> stop 
        test    al, al          
        jnz     elseE

        pop     ax bx cx dx si di bp sp
        jmp     exit_handler

elseE:
        ; else
        ; saving screen and drawing

        ; preparing for saving srceen 
        mov     cx, Y                                   ; string length in cx
        mov     di, offset buff_new                     ; buff addr in di
        push    es                                      ; saving
        push    cs 
        pop     es                                      ; cs in es
        mov     si, (80d * YStart + Xstart) * 2          ; start point 
        mov     dx, X                                   ; dx string amount
        push    ds                                      ; saving before call
        push    0b800h
        pop     ds                                      ; videoseg in ds

        call    SaveScreen 

        pop     ds                                      ; restoring
        pop     es                                      ; restoring

        ;preparing for drawing frame
        push    cs 
        pop     es                                      ; cs in es
        mov     bx, X                                   ; strings amount in bx
        mov     si, offset symbols
        mov     di, offset buff_new

        call    DrawFrame

        mov     di, offset buff_new
        add 	di, (Y + 1) * 2 ; start point in buff

        call    printRegs

        ; now we need print our buff to screen

        push    cs 
        pop     ds                               ; cs in ds
        push    0b800h
        pop     es                               ; videoseg in es
        mov     di, (YStart * 80d + Xstart) * 2  ; start point
        mov     si, offset buff_new
        mov     cx, Y 
        mov     dx, X 

        call    print_buff

exit_handler:
        pop     ds es 
        popa

        iret


        ;####################################################################################################
        X	        = 10			;  hight
        Y	        = 9			;  length
        Xstart	        = 60
        YStart          = 5
        VIDEOSEG	= 0b800h		
        COLOR 		= 4eh			;  orange

        


        symbols         db      '+', '-', '+', '|', '+', '-', '+'     ; array with symbs for frame

        is_on           db      1
        old_int09h      dd      ?
        old_int1Ch      dd      ?

        buff_old        dw      300 dup(' ')      ; video buff on previous step
        buff_new        dw      300 dup(' ')      ; video buff on current  step

        reg_value       db      4 dup('0')
        ;####################################################################################################

int1Ch_handler  endp

        
        include         showregs.ASM    ; including files
        include         drawing.ASM     ; for new int1Ch_handler
        include         srn.ASM         ; for saving and restoring screen


int09h_handler proc near

        pushf
        call    dword ptr cs:old_int09h

        pusha                   ; saving regs
        push    es ds

        push    0040h
        pop     ds                      ; bios seg in ds

        mov     di, word ptr ds:001Ah   ; head of kb buff
        cmp     di, word ptr ds:001Ch   ; tail of kb buff
        je      exit_09h_handler

        mov     al, byte ptr ds:0017h   ; get kb status

        cmp     al, 08h                 ; if alt pressed
        jne     exit_09h_handler

        mov     ax, word ptr [di]       ; read symb

        cmp     ah, 1Eh                 ; if A pressed
        jne     F_check

        push    es
        push    cs
        pop     es
        mov     es:[is_on], 1           ; turning programm on
        pop     es                      

        ; now we need clear buff for next command
        mov     word ptr ds:001Ch, di   ; clear buff
        jmp     exit_09h_handler


F_check:
        cmp     ah, 21h                 ; if F pressed
        jne     exit_09h_handler

        push    cs
        pop     es
        mov     dl, es:[is_on]
        test    dl, dl 
        jz     clear_buf                ; if program already turned off

        push    di                      ; saving before call

        ; preparing before call restore_screen
        mov     dx, offset buff_old
        mov     si, dx                          ; buff in si
        mov     di, (80 * YStart + Xstart) * 2  ; start point in di
        mov     cx, Y                           ; length in cx
        mov     dx, X                           ; hight in dx
        push    0b800h
        pop     es                              ; 0b800h in es
        push    cs
        pop     ds                              ; cs in ds

        call    print_buff

        push    es
        push    cs
        pop     es
        mov     es:[is_on], 0                   ; turning programm off
        pop     es

        pop     di                              ; restore after call

clear_buf:
        mov     word ptr ds:001Ch, di           ; clear buff


exit_09h_handler:
        pop     ds es
        popa

        iret

int09h_handler  endp

resident_end:


initialize:

        cli

        ;saving old int09h
        mov     ax, 3509h               ; AH = 35h, AL = number of int
        int     21h                     ; detect addr of int

        mov     word ptr old_int09h, bx
        mov     word ptr old_int09h + 2, es

        ; set my own int09h

        mov     ax, 2509h
        mov     dx, offset int09h_handler
        int     21h 

        ; saving old 1Ch
        mov     ax, 351Ch               ; AH = 35h, AL = number of int
        int     21h                     ; detect addr of int

        mov     word ptr old_int1Ch, bx
        mov     word ptr old_int1Ch + 2, es

        ; set my own int1Ch

        mov     ax, 251Ch
        mov     dx, offset int1Ch_handler
        int     21h 

        sti

        mov     ax, 3100h
        mov     dx, (resident_end - start + 10Fh) / 16

        int     21h

end     start


