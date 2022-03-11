.model  tiny
.code
.186
org     100h

start:

        jmp     initialize

int09h_handler  proc    near

        pushf
        call    dword ptr cs:old_int09h   ; 

        pusha                   ; saving regs
        push    es ds

        push    0b800h
        pop     es              ; videoseg in es

        push    0040h
        pop     ds              ; bios seg in ds

        mov     di, word ptr ds:001Ah   ; head of kb buff
        cmp     di, word ptr ds:001Ch   ; ds:001Ch tail of kb buff
        je      exit_09h_handler        ; if buff is empty


        mov     al, byte ptr ds:0017h

        cmp     al, 08h                 ; if alt pressed
        jne     good

        mov     ax, word ptr [di]       ; read symb

        cmp     ah, 1Eh                 ; if not A
        jne     exit_09h_handler

        mov      word ptr ds:001Ch, di  ; clear buff

        mov     [symb], 4e24h
        mov     ax, symb
        mov     di, (80 * 4 + 20) * 2
        stosw

        jmp     exit_09h_handler

good:
        mov    [symb], 4e25h
        mov    ax, symb
        mov    di, (80 * 4 + 20) * 2
        stosw


exit_09h_handler:

        pop     ds es
        popa

        iret

        symb            dw      ?
        old_int09h      dd      ?

int09h_handler  endp

resident_end:

initialize:

        mov	ax, 3509h
        int     21h

        mov     word ptr old_int09h, bx
        mov     word ptr old_int09h + 2, es

        mov     ax, 2509h
        mov     dx, offset int09h_handler
        int     21h


        ;stay resident
        mov     ax, 3100h
        mov     dx, (resident_end - start + 10Fh) / 16
        int     21h 

end     start