		title   Sonic Fan Games HQ Splash Screen
		type	8521
		program
;============================================================================		
SFGHQ_Bank	equ     39

SFGHQ_Update:
		call	Wait10Seconds
		mov 	nextGState, #1
		jmp 	Game_ChangeState

SFGHQ_Draw:
		mov		r8,#0			; Horizontal screen displacement
		mov		r9,#0			; Vertical screen displacement
		mov		r10,#0			; Horizontal graphic offset 
		mov		r11,#0			; Vertical graphic offset 
		mov		r12,#200		; Horizontal size
		mov		r13,#160		; Vertical size
		mov		r14,#SFGHQ_Bank	; Bank #
		mov		r15,#0			; Write mode
		call 	FBDrawGraphicF
		ret
;============================================================================
		end
;============================================================================