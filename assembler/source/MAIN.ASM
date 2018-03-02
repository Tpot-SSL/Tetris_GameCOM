; ===========================================================================
		title   Tetris
		type	8521
		org	4000h
; ---------------------------------------------------------------------------		
		NLIST
		include source/EQUATES.INC		; Equates
		LIST		
; ---------------------------------------------------------------------------		
		program	
		
		global Game_FadeIn
		global Game_FadeOut

; ===========================================================================	
		db      08h
		db      20h
		dw      EntryPoint
		db      00000011b           ;3
		dm      'TigerDMGC'
		db      24h	         		;icon located bank no.
		db      0                  	;x_coord.
		db      160                 ;y_coord.
		dm      'TetrisTGM'			; Game Title
		dw      1A18h				; Game ID (just something random here)
		db      97h
		db      0
		dw      0
; ===========================================================================	
EntryPoint:
		clr     r0
		cmp     r2,#0			; is the Game.COM turning on from a cold boot?
		br      eq,GameInit		; if so, branch
		cmp     r2,#1			; has the game been entered from the main menu?
		jmp     eq,Game_Exe		; if so, branch
		cmp     r2,#2			; is the game being closed?
		br      eq,GameInit		; if so, branch
		cmp     r2,#3			; is the game being reset?
		br      eq,GameInit		; if so, branch
		mov     r0,#-1			; otherwise, indicate that none of the above conditions were able to be met
		ret				; return
; ---------------------------------------------------------------------------
GameInit:
		ret				; return, doing nothing
; ---------------------------------------------------------------------------		
Game_Reset:
Game_Exe:
		mov		fadeStep,#255
		mov 	gameState,#0
Game_State:
		call    Game_FadeIn
		call	Game_Update
Game_Update:
		cmp 	gameState, #0
		jmp 	eq, SFGHQ_Update
		cmp 	gameState, #1
		jmp 	eq, Tetris_Update
		
		jmp		Game_Update
Game_Draw:
		cmp 	gameState, #0
		jmp 	eq, SFGHQ_Draw
		cmp 	gameState, #1
		jmp 	eq, Tetris_Draw
		ret
Game_FadeIn:
		call	WaitForVInt	
		mov		r0,fadeStep
		dec		r0
		mov		fadeStep,r0

		call	Game_Draw	
		
		cmp		r0,#111
		jmp		ne,Game_FadeIn
		
		ret
Game_ChangeState:
		call    Game_FadeOut
		mov		gameState,nextGState
		call    Game_FadeIn
		jmp		Game_Update
		
Game_FadeOut:
		call	WaitForVInt	
		mov		r0,fadeStep
		inc		r0
		mov		fadeStep,r0
		
		call	Game_Draw	
		
		cmp		r0,#255
		jmp		ne,Game_FadeOut
		ret

; ===========================================================================	
		include	source/SYSCALL.ASM
; ---------------------------------------------------------------------------
		include	source/FUNCS.ASM
; ---------------------------------------------------------------------------
		include	source/SFGHQ.ASM
; ---------------------------------------------------------------------------
		include	source/TETR_G.ASM
; ---------------------------------------------------------------------------
	end