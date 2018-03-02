		title   Tetris Gameboard
		type	8521
		program
;============================================================================	

Tetris_Bank1  equ     024h
Tetris_Bank2  equ     021h

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
Tetris_Update:
		jmp Tetris_Update
Tetris_Draw:
		call	FBFillColor
		call 	Tetris_DrawField
		call	FBDrawChar
		ret
;============================================================================
		end
;============================================================================