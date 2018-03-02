; ===========================================================================	
		title   Various functions
		type	8521
		program
; ===========================================================================	

; ===========================================================================
; Subroutine to wait a given amount of seconds
; ===========================================================================	
Wait10Seconds:
		mov	r1,#2

waitloop:
		mov	r0,#255
onesecond:
		call	WaitForVInt
		dec	r0
		cmp	r0,#0
		br	nz,onesecond

		dec	r1
		cmp	r1,#0
		br	nz,waitloop

		ret

; ===========================================================================
; Subroutine to read the player's input
; ===========================================================================	
ReadInput:
;		call	SCAN_KEY		; use the system call to read the current inputs
		mov	playerInput,r0		; store the input to RAM
		ret
; ===========================================================================
; Subroutine to wait for a vertical interrupt
; ===========================================================================	
WaitForVInt:
		pushw	rr2					; store rr2 onto the stack
		push	r0					; store r0 onto the stack
		push	r1					; store r1 onto the stack

		movw	rr2,#0112h			; load the DMG_timer into rr2
		mov	r1, prevVtick			; load the previous V-Int tick into r1
		
WaitForVInt_Wait:
		mov	r0,	0(rr2)				; load the value of the timer into r0
		cmp	r0,	r1					; is the timer on the same tick as before?
		br	eq,	WaitForVInt_Wait	; if so, loop and wait
		
		mov	prevVtick,r0			; store the new V-Int tick

		pop	r1						; restore r1 from the stack		
		pop	r0						; restore r0 from the stack
		popw	rr2					; restore rr2 from the stack
		ret							; return
; ===========================================================================	
StrCharY        equ     251
StrCharBank     equ     21h
StrCharWid      equ     5

FBDrawChar:
		mov		r10,#5			; for testing, draw the number '1'
		mov		r11,#StrCharY
		mov		r12,#StrCharWid
		mov		r13,#StrCharWid
		mov		r14,#StrCharBank
		mov		r15,#0
		call	FBDrawGraphic		
		
		ret
; ===========================================================================	
		end
; ===========================================================================	