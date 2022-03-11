;------------------------------------------------
;ITOA
;Entry:
;       AX - number
;       DI - addr of res array
;       BX - radix
;Destr: AX, DX, DI
;Ret:
;------------------------------------------------

itoa    proc

        push    di              ; addr of res arr in stack
                                ; for reverse

NextItoa:

        xor     dx, dx

        div     bx              ; in dx the remainder of the division
                                ; in ax quotient of division

        push    ax              ; now quotient in stack
        mov     ax, dx          ; preparing before hex2ascii

        call    hex2ascii       ; in ax now ascii of number

        mov     ah, 4eh

        stosb                   ; now we have last number at first place in 

        pop     ax              ; now quotient in ax

        test    ax, ax

        ja      NextItoa

        pop     si              ; addr of res arr in si
                                ; for strlen

        mov     cx, 4

        mov     dx, si
        add     dx, cx
        dec     dx              ; addr of last symb in dx 

        mov     di, dx          ; di have tail of array


ReverseItoa:

        mov     al, [si]
        mov     bl, [di]

        mov     [si], bl
        mov     [di], al

        inc     si
        dec     di

        cmp     si, di
        jb      ReverseItoa

        ret

itoa    endp


;------------------------------------------------
;hex2ascii 
;Entry:
;       AL - one HEX symb 0-F
;Ret:
;       AL - ASCII-code of symb
;Destr: AL
;------------------------------------------------
hex2ascii       proc
        cmp     al, 10
        sbb     al, 69h
        das

        ret
endp


;------------------------------------------------
;printRegs
;Entry:
;       DI - addr of first elem in video seg
;Ret:
;
;Destr: AX, DI, DX, SI
;------------------------------------------------
PrintValue      macro
LOCAL   PrintToSreen

        ; preparing for call itoa

        pop     ax                      ; reg value in ax   
        mov     dx, offset reg_value
        push    di                      ; saved for printing
        mov     di, dx
        mov     bx, 16d

        xor     dx, dx
        push    cs
        pop     es

        call    itoa                    ; now in reg_value we have reg value

        mov     dx, offset reg_value
        mov     si, dx
        pop     di                      ; pop saved before call value 

        mov     ah, COLOR
        mov     cx, 4
        push    cs 
        pop     es


PrintToSreen:                           ; printing string with reg value
        lodsb
        stosw
        loop    PrintToSreen


        add     di, 4d                  ; for next string in buff

endm

;------------------------------------------------
; Macro for printing info about reg
;------------------------------------------------
printOneReg     macro   name1, name2

        mov     al, '&name1&'   ; printing
        stosw                   ; reg
        mov     al, '&name2&'   ; name
        stosw                   ;
        mov     al, ' '         ; and one space before number
        stosw

        PrintValue              ; and value

endm


;------------------------------------------------
; Entry:
;       DS - CS
;       ES - CS
;       DI - first position in buff
;Destr: AX, SI, BI, DX, BX, CX
;------------------------------------------------
printRegs       proc    near

        pop     bp              ; bp have ret addr of printRegs

        ;push    sp bp di si dx cx bx ax ; we have all regs saved in stack
        ;       ^
        ;       |
        ;       |
        ;we did it before

        mov     ah, COLOR

        printOneReg a, x 
        printOneReg b, x 
        printOneReg c, x 
        printOneReg d, x
        printOneReg s, i 
        printOneReg d, i 
        printOneReg b, p 
        
        ; now we need fix sp value
        pop     ax      ; old sp value in ax
        add     ax, 8   ; fixed
        push    ax      ; now correct sp value in stack

        mov     ah, COLOR

        printOneReg s, p

        push    bp      ; ret addr now is ready for ret

        ret

endp    printRegs
        
