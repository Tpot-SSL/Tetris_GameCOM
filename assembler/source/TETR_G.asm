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
		call	FBDrawGraphicF			; Render the background to Page A
		mov		r15,#2			    ; Write mode
		call	FBDrawGraphicF			; Render the background to Page B
		
		mov		r8,#0
		mov		r9,#0
		mov		r10,#200
		mov		r11,#0
		mov		r12,#43				; Horizontal size
		mov		r13,#160			; Vertical size
		mov		r14,#Tetris_Bank2	; Bank #
		mov		r15,#0				; Write mode
		call	FBDrawGraphicF
		mov		r15,#2			    ; Write mode
		call	FBDrawGraphicF			; Render the background to Page B
		ret

;============================================================================
; Main game update loop
;============================================================================		
Tetris_Update:
		mov	tetrisPieces,#0		; completely clear out the stored tetris pieces
		mov	tetrisPieces+1,#0

		; generating the first four tetris pieces
		call	RNGenerator		; first tetrimino
		and	r0,#3
		mov	r1,r0
		swap	r1
		call	RNGenerator		; second tetrimino
		and	r0,#7
		or	r1,r0
		mov	tetrisPieces,r1
		call	RNGenerator		; third tetrimino
		and	r0,#7
		mov	r1,r0
		swap	r1
		call	RNGenerator		; fourth tetrimino
		and	r0,#7
		or	r1,r0
		mov	tetrisPieces+1,r1
		
;		mov	r0,#1
		mov	r0,tetrisPieces
		swap	r0
		and	r0,#7
		call	GetTPLayout

		mov	currPieceX,#50		; TEST X
		mov	currPieceY,#10		; TEST Y

;----------------------------------------------------------------------------
; Game's main loop
;----------------------------------------------------------------------------
Tetris_MainLoop:
		call	WaitForVInt		
;		call	ReadInput		; TESTING INPUT CODE

		; clear the playing field with a white rectangle
		movw	rr8,#2C00h
		movw	rr10,#50A0h		; 80 wide, 160 tall
		mov	r12,#0
		cmp     currPage,#1
		br      eq,Tetris_ClrBG
		bset    r12,#4
Tetris_ClrBG:
		call	FBFillColorRect
		
		mov	r8,#50
		mov	r9,#10		
		movw	rr2,#Test_String
		call	FBDrawString
		
		call	Render_TP		; render the Tetrimino

		; END OF MAIN LOOP
		call	FBSwapPage		; swap the page to the newly rendered screen		
		jmp	Tetris_MainLoop		; loop

Test_String:	
		defm	'HELLO FROM STONE'
		db	0FFh		; end of string		
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