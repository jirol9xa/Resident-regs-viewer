;------------------------------------------------
;cmp_scrn - compare screen and our buff for restoring
;Entry:
;       ES - CS
;       DI - buff_old offset
;       DS - videoseg
;       SI - start point of frame
;       CX - string length
;       DX - string amount
;Destr: DI, SI, AX, CX, DX
;------------------------------------------------
cmp_scrn        proc    near

again_scrn:
        lodsw   ; now symb in ax

        scasw   ; compare ax and es:[di]
        je      rep_scrn

        ; if not equal we need rewrite old buff from screen

        sub     di, 2   ; after scaws
        stosw           ; now symb is in buff
        jmp     rep_scrn

rep_scrn:
        loop    again_scrn

        ; when string done

        dec     dx
        mov     cx, Y 

        add     si, 160d
        sub     si, Y * 2

        test    dx, dx
        jnz     again_scrn

        ret

cmp_scrn        endp

;------------------------------------------------
;SaveScreen
;Entry:
;       SI - addr in video seg of first 
;       CX - legth of string
;       DX - strings amoint
;       DI - buff addr
;       DS - videoseg
;       ES - CS
;Destr:
;       AX, CX, DX, SI, DI, ES
;------------------------------------------------
SaveScreen      proc    near

        push    si cx dx 

again:
        lodsw   ; now symb in ax

        scasw   ; compare ax and es:[di]        ; wrong working
        je      equal2

        ; if not equal we need rewrite old buff from screen

        ; preparing for call cmp_scrn (rewrite buff)

        pop     dx cx si                ; args for cmp_scrn

        push    offset buff_old
        pop     di                      ; buff_old addr for cmp_scrn

        call    cmp_scrn

        jmp     save_finish

equal2:
        loop    again

        ; when string done

        dec     dx
        mov     cx, Y 

        add     si, 160d
        sub     si, Y * 2

        test    dx, dx
        jnz      again

        pop     dx cx si        ; for balansing stack

save_finish:
        ret 

SaveScreen      endp
