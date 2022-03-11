;------------------------------------------------
;Draw line:
;Entry:
;       CX - string length
;       SI - array with symbs
;       DI - addr dest
;Destr:
;       AX, DI, SI, CX
;------------------------------------------------
Drawline	proc
		
	mov 	cx, Y

	lodsb                   ; first symb in ax
	stosw					; now in buff

	lodsb                   ; middle symb in ax

	sub 	cx, 2
	jbe 	stopline
		
nextSym:	
	stosw
	dec  	cx
	ja  	nextSym

stopline:	
	lodsb           ; last symb in ax
        stosw
	
	mov 	cx, Y

	ret

Drawline        endp


;------------------------------------------------
;DrawFrame:
;Entry:
;	BX - hight of frame
;	For drawing frame with DrawLine
;	ES - CS
;	DI - buff_new addr
;	SI - arr with symbs
;Destr: AX BX CX SI 
;------------------------------------------------

DrawFrame	proc
	
	mov	ah, COLOR

	call 	DrawLine		;first string			
		
	sub 	bx, 1
	
	lodsb   ; symb in a

middle:	
	stosw

	add     di, (Y - 2) * 2 ; skip middle of string

        stosw

        dec     bx
        cmp     bx, 1
        ja      middle
	
lastString:   
	call 	DrawLine	

        ; now we have frame in our buff

	ret	
			
DrawFrame       endp


;------------------------------------------------
;print_buff
;       DS - CS
;       ES - videoseg
;       DI - start position
;       SI - offset buff_new
;       CX - string length
;       DX - string amount
;Destr: AX, SI, Di, CX, DX
;-------------------------------------------------

print_buff      proc    near

string_again:
        lodsw
        stosw
        loop    string_again    ; one string print

        dec     dx

        add     di, 160d
        sub     di, Y * 2

        mov     cx, Y

        test    dx, dx
        jnz     string_again

        ret
endp
