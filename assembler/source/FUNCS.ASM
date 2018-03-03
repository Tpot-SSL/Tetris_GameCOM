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
StrCharBank     equ     39
StrCharWid      equ     5

FBDrawChar:
		mov	r11,r10
		mov	r10,#0
		mult	rr10,#StrCharWid
		mov	r10,r11
		mov	r11,#StrCharY
		mov	r12,#StrCharWid
		mov	r13,#StrCharWid
		mov	r14,#StrCharBank
		mov	r15,#049h
		call	FBDrawGraphic		
		
		ret
; ===========================================================================	
; Subroutine to write a string on screen
; Input:
; rr0 = String's address
; r8 = String's X-position
; r9 = String's Y-position
; ===========================================================================
FBDrawString:
		movw	rr2,#Test_String
		
DrwStr_Chr:
		mov	r0,(rr2)+
		cmp	r0,#0FFh	; is the character a terminator?
		br	eq,DrwStr_END	; if so, branch
		cmp	r0,#020h	; is the character a space?
		br	eq,DrwStr_Spc	; if so, branch
		cmp	r0,#041h	; is the character from the alphabet?
		br	uge,DrwStr_Alph	; if so, branch
		cmp	r0,#030h	; is the character numeric?
		br	uge,DrwStr_Num	; if so, branch
		jmp	DrwStr_END	; otherwise, panic and leave
		
DrwStr_Spc:
		mov	r0,#44
		br	DrwStr_Do
				
DrwStr_Num:
		cmp	r0,#039h	; is the character numeric? (checking for 9)
		br	ugt,DrwStr_END	; if not, panic and leave
		sub	r0,#030h
		br	DrwStr_Do
				
DrwStr_Alph:
		cmp	r0,#05Ah	; is the character from the alphabet? (checking for Z)
		br	ugt,DrwStr_END	; if not, panic and leave
		
		
		sub	r0,#037h
		br	DrwStr_Do

DrwStr_Do:		
		mov	r10,r0
		push	r8
		push	r9
		call	FBDrawChar	; otherwise, draw the character
		pop	r9
		pop	r8
		add	r8,#6		; increase the X-position for the next character
		br	DrwStr_Chr
		
DrwStr_END:		
		ret

Test_String:		
		db	'H'
		db	'E'
		db	'L'
		db	'L'
		db	'O'
		db	' '
		db	'F'
		db	'R'
		db	'O'
		db	'M'
		db	' '
		db	'S'
		db	'T'
		db	'O'
		db	'N'
		db	'E'
		db	0FFh		; end of string
; ===========================================================================	
		end
; ===========================================================================	