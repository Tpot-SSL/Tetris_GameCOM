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

		movw	gravFactor,#4

		mov	currPieceX,#59		; TEST X
		mov	currPieceY,#64		; TEST Y

;----------------------------------------------------------------------------
; Game's main loop
;----------------------------------------------------------------------------
Tetris_MainLoop:
		call	WaitForVInt		
;		call	ReadInput		; TESTING INPUT CODE
		call	Tetris_Logic

		; clear the playing field with a white rectangle
		mov	r8,#43
		mov	r9,#0
		mov	r10,#80
		mov	r11,#160
		mov	r12,#0
		cmp     currPage,#1
		br      eq,Tetris_ClrBG
		bset    r12,#4
Tetris_ClrBG:
		call	FBFillColorRect
		
;		mov	r8,#50
;		mov	r9,#10		
;		movw	rr2,#Test_String
;		call	FBDrawString
		
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
; Handling Tetronimo logic
;============================================================================
Tetris_Logic:
		call	Tetr_Shift


		; automatically falling
		movw	rr0,gravFactor
		addw	currPieceGrav,rr0
		cmp	currPieceGrav,#1
		br	ult,TetLog_END
		mov	r1,currPieceGrav
		sll	r1
		sll	r1
		sll	r1
;		add	currPieceY,r1		; UNCOMMENT TO REENABLE GRAVITY AFTER TESTING
		mov	currPieceGrav,#0
		
TetLog_END:
		ret
;----------------------------------------------------------------------------		
Tetr_Shift:
		call	IOInputScan		; use the system call to read the current inputs
		cmp	r0,#inputLeft		; is left pressed?
		br	ne,TetrShft_ChkR	; if not, branch
		sub	currPieceX,#8

TetrShft_ChkR:
		cmp	r0,#inputRight		; is right pressed?
		br	ne,TetrShft_END		; if not, branch
		add	currPieceX,#8
		
TetrShft_END:
		call	Chk_ValidPos		; keep the positions in check
		ret				; return
;----------------------------------------------------------------------------			
Chk_ValidPos:
		movw	rr2,#currPieceLyt
		mov	r2,#4

Chk_LWall:
		; ---- X CHECKS ----
		mov	r0,0(rr2)		; get the current block's X displacement
		add	r0,currPieceX		; add the Tetrimino's base X pos to the displacement
	
		cmp	r0,#51			; is the piece within the wall?
		br	uge,Chk_RWall		; if not, branch
		mov	currPieceX,#51
		
Chk_RWall:
		cmp	r0,#115		; is the piece within the right wall?
		br	ule,Chk_Floor		; if not, branch
		mov	currPieceX,#115
		
		; NOTE TO SELF: ADD OTHER TETRIMINO COLLISION HERE
		
		; ---- Y CHECKS ----
Chk_Floor:
		mov	r0,1(rr2)		; get the current block's X displacement
		add	r0,currPieceY		; add the Tetrimino's base X pos to the displacement
		cmp	r0,#144
		br	ule,Chk_NxtPce
		mov	currPieceY,#144
		; SET FLAG FOR PLACEMENT HERE
		
Chk_NxtPce:
		addw	rr2,#2
		dec	r2
		br	nz,Chk_LWall
		ret
;============================================================================
		end
;============================================================================