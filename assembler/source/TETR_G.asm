		title   Tetris Gameboard
		type	8521
		program
;============================================================================	

Tetris_Bank1  equ     36
Tetris_Bank2  equ     39

Tetris_DrawField:
		mov		r8,#123
		mov		r9,#0
		mov		r10,#0
		mov		r11,#0
		mov		r12,#77			    ; Horizontal size
		mov		r13,#160		    ; Vertical size
		mov		r14,#Tetris_Bank1	; Bank #
		mov		r15,#0			    ; Write mode
		call	FBDrawGraphicF
		
		mov		r8,#0
		mov		r9,#0
		mov		r10,#200
		mov		r11,#0
		mov		r12,#43				; Horizontal size
		mov		r13,#160			; Vertical size
		mov		r14,#Tetris_Bank2	; Bank #
		mov		r15,#0				; Write mode
		call	FBDrawGraphicF
		ret

;============================================================================
; Main game update loop
;============================================================================		
Tetris_Update:
		call	WaitForVInt
		
		mov	r8,#50
		mov	r9,#10		
;		mov	r10,#2	
		call	FBDrawString

;		mov	r10,#0
;		mov	r11,#224
;		mov	r12,#6
;		mov	r13,#6
;		mov	r14,#39
;		mov	r15,#01h
;		call	FBDrawGraphic
		
;		mov	r10,#0
;		mov	r11,#236
;		mov	r12,#6
;		mov	r13,#6
;		mov	r14,#39
;		mov	r15,#09h
;		call	FBDrawGraphic

		jmp Tetris_Update
		
;============================================================================
; Screen fade drawing routine
;============================================================================
Tetris_Draw:
;		call	FBFillColor
		call 	Tetris_DrawField
		ret
;============================================================================
		end
;============================================================================