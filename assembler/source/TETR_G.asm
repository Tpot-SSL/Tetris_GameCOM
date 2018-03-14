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

		; clear the playfield
		movw	rr2,#playfieldMap
		mov	r0,#100
		mov	r1,#077h		; fill with blank blocks (ID 7)
Tetris_ClrPlyfld:
		mov	(rr2)+,r1
		dec	r0
		br	nz,Tetris_ClrPlyfld
		
		; generating the first four tetris pieces
		call	RNGenerator		; first tetrimino
		mov	r0,pieceRNG
		and	r0,#3
		mov	r1,r0
		swap	r1
		call	RNGenerator		; second tetrimino
		mov	r0,pieceRNG
		and	r0,#7
		or	r1,r0
		mov	tetrisPieces,r1
		call	RNGenerator		; third tetrimino
		mov	r0,pieceRNG
		and	r0,#7
		mov	r1,r0
		swap	r1
		call	RNGenerator		; fourth tetrimino
		mov	r0,pieceRNG
		and	r0,#7
		or	r1,r0
		mov	tetrisPieces+1,r1
		
		mov	r0,tetrisPieces
		swap	r0
		and	r0,#7
		call	GetTPLayout		; get the layout for the first Tetrimino

		mov	gameType,#0		; for now, set the game to Type A (type B to be handled later)
		
		movw	gravFactor,#20
		mov	currPiecePlce,#0	; clear the Tetrimino placement flag

		mov	currPieceX,#75		; TEST X
		mov	currPieceY,#40		; TEST Y

;----------------------------------------------------------------------------
; Game's main loop
;----------------------------------------------------------------------------
Tetris_MainLoop:
		call	WaitForVInt		
		call	ReadInput		; TESTING INPUT CODE
		call	Tetris_Logic
		call	Render_UI
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
		call	FBFillColorRect		; clear the playfield section out with white
		call	Render_Plyfld		; draw the already placed blocks
		call	Render_TP		; render the current Tetrimino

		; END OF MAIN LOOP
		call	FBSwapPage		; swap the page to the newly rendered screen		
		jmp	Tetris_MainLoop		; loop
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
		call	Tetr_ClrdLines		; check for cleared lines
		call	Tetr_Grav		; automatically pull the Tetrimino down
		call	Tetr_Shift		; let the player shift the Tetrimino
		call	Tetr_PlacePiece		; check if the Tetrimino should be placed
		
TetLog_END:
		ret				; return
;----------------------------------------------------------------------------		
Tetr_ClrdLines:
		pushw	rr2
		pushw	rr4
		pushw	rr6

		movw	rr2,#playfieldMap	; load the playfield map into rr2
		movw	rr10,rr2
		movw	rr4,#clrLineMap
		mov	r7,#20			; 20 rows
		
TetrChkClr_NxtRow:
		mov	r6,#5			; 10 wide
		
TetrChkClr_NxtSlot:
		mov	r0,(rr2)+		; copy two blocks to r0
		mov	r1,r0			; copy r0 to r1
		and	r0,#070h		; isolate the first block
		and	r1,#007h		; isolate the second block
		swap	r0
		cmp	r0,#7			; is the first block in the current spot blank?
		br	eq,TetrChkClr_ChkNxt	; if so, branch
		cmp	r1,#7			; is the second block in the current spot blank?
		br	eq,TetrChkClr_ChkNxt	; if so, branch
		dec	r6			; decrease the loop counter
		br	nz,TetrChkClr_NxtSlot	; if there are still blocks to be checked, branch
		mov	r0,#1
		mov	0(rr4),r0		; set flag to indicate this line on the playfield should be cleared
		inc	r8			; increment the relative cleared line counter

TetrChkClr_ChkNxt:
		addw	rr4,#1			; go to the next playfield row flag
		addw	rr10,#5
		movw	rr2,rr10
		dec	r7
		br	nz,TetrChkClr_NxtRow
		cmp	r8,#0			; were any lines cleared?
		br	eq,TetrClrLn_END	; if not, branch and exit
		add	linesClr,r8	
		
		; REMOVE THE CLEARED LINES
		movw	rr2,#playfieldMap	; load the beginning of the playfield map into rr2
		movw	rr4,#clrLineMap		; load the cleared line map into rr4
		mov	r6,#20			; 20 rows

TetrClrLn_ChkClrRow:		
		mov	r0,(rr4)+
		cmp	r0,#0			; is this row to be cleared?
		br	eq,TetrClrLn_GoNxt	; if not, branch
		mov	r7,#5
		mov	r0,#077h
TetrClrLn_ClrRow:		
		mov	(rr2)+,r0		; clear two blocks
		dec	r7
		br	ne,TetrClrLn_ClrRow	; loop until the entire current row is cleared
TetrClrLn_GoNxt:
		addw	rr2,#5			; go to the next row in the playfield map
		dec	r6			; decrement the row loop counter
		br	nz,TetrClrLn_ChkClrRow	; loop until each row has been checked for clearing
		
		; RESET THE CLEARED LINE MAP
		mov	r0,#0
		mov	r1,#20
		movw	rr4,#clrLineMap
TetrClLnMp_Clr:
		mov	(rr4)+,r0
		dec	r1
		br	nz,TetrClLnMp_Clr
		
		; SHIFT THE MAP DOWNWARDS ACCORDINGLY
		movw	rr2,#playfieldMap
		addw	rr2,#95			; start on the last line of the playfield map
		movw	rr10,rr2
		
TetrClrLn_END:		
		popw	rr6
		popw	rr4
		popw	rr2
		ret				; return
;----------------------------------------------------------------------------		
Tetr_Shift:
		btst	playerPress+1,#inputLeft	; is left pressed?
		br	z,TetrShft_ChkR			; if not, branch
		call	Tetr_ChkLBump

TetrShft_ChkR:
		btst	playerPress+1,#inputRight	; is right pressed?
		br	z,TetrShft_ChkA			; if not, branch
		call	Tetr_ChkRBump
		
TetrShft_ChkA:
		btst	playerPress+1,#inputA		; is A pressed?
		br	z,TetrShft_ChkDwn		; if not, branch
		call	Rotate_TP
		
TetrShft_ChkDwn:
		movw	gravFactor,#20
		btst	playerHeld+1,#inputDown		; is down pressed?
		br	z,TetrShft_END			; if not, branch
		movw	gravFactor,#200

TetrShft_END:
		call	Tetr_ChkBound		; keep the positions in check
		ret				; return
;----------------------------------------------------------------------------
Tetr_ChkLBump:
		cmp	currPieceX,#43		; is the block up against a wall?
		br	ule,TetrChkBmpL_END	; if so, don't bother doing the check

		push	r0
		pushw	rr2
		pushw	rr4
		
		mov	r6,#4
		movw	rr2,#currPieceLyt	; load the current Tetrimino layout into rr2		
		
TetrChkBmpL_Blk:
		movw	rr4,#playfieldMap	; load the playfield map into rr4

		mov	r0,1(rr2)		; get the current block's Y displacement		
		add	r0,currPieceY		; add the Y position
		srl	r0
		srl	r0
		srl	r0
		mov	r1,r0
		mov	r0,#0
		mult	rr0,#5
		addw	rr4,rr0			; add the Y displacement to the playfield map address
		
		mov	r0,0(rr2)		; get the current blocks' X displacement
		add	r0,currPieceX		; add the X position
		sub	r0,#43			; subtract the wall offset, getting the raw position
		srl	r0
		srl	r0
		srl	r0
		push	r0
		srl	r0
		mov	r1,r0
		mov	r0,#0
		addw	rr4,rr0
		pop	r0
		
		and	r0,#1
		cmp	r0,#0			; is the block pos even or odd?
		br	eq,TetrChkBmpL_Read	; if even, branch
		mov	r1,0(rr4)
		and	r1,#070h
		swap	r1
		br	TetrChkBmpL_Cmp
		
TetrChkBmpL_Read:
		mov	r1,-1(rr4)
		and	r1,#07h

TetrChkBmpL_Cmp:
		cmp	r1,#7			; is the block to the left blank?
		br	ne,TetrChkBmpL_REND	; if not, branch

		addw	rr2,#2
		dec	r6
		br	nz,TetrChkBmpL_Blk	; if there are still blocks left to be handled, branch
		sub	currPieceX,#8		; otherwise, all has checked out, and the block can move right

TetrChkBmpL_REND:
		popw	rr4
		popw	rr2
		pop	r0

TetrChkBmpL_END:
		ret
;----------------------------------------------------------------------------
Tetr_ChkRBump:
		cmp	currPieceX,#115		; is the block up against a wall?
		br	uge,TetrChkBmpR_END	; if so, don't bother doing the check

		push	r0
		pushw	rr2
		pushw	rr4
		
		mov	r6,#4
		movw	rr2,#currPieceLyt	; load the current Tetrimino layout into rr2

TetrChkBmpR_Blk:		
		movw	rr4,#playfieldMap	; load the playfield map into rr4

		mov	r0,1(rr2)		; get the current block's Y displacement		
		add	r0,currPieceY		; add the Y position
		srl	r0
		srl	r0
		srl	r0
		mov	r1,r0
		mov	r0,#0
		mult	rr0,#5
		addw	rr4,rr0			; add the Y displacement to the playfield map address
		
		mov	r0,0(rr2)		; get the current blocks' X displacement
		add	r0,currPieceX		; add the X position
		sub	r0,#43			; subtract the wall offset, getting the raw position
		srl	r0
		srl	r0
		srl	r0
		push	r0
		srl	r0
		mov	r1,r0
		mov	r0,#0
		addw	rr4,rr0
		pop	r0
		
		and	r0,#1
		cmp	r0,#0			; is the block pos even or odd?
		br	eq,TetrChkBmpR_Read	; if even, branch
		mov	r1,1(rr4)
		and	r1,#070h
		swap	r1
		br	TetrChkBmpR_Cmp
		
TetrChkBmpR_Read:
		mov	r1,0(rr4)
		and	r1,#07h

TetrChkBmpR_Cmp:
		cmp	r1,#7			; is the block to the right blank?
		br	ne,TetrChkBmpR_REND	; if not, branch

		addw	rr2,#2
		dec	r6
		br	nz,TetrChkBmpR_Blk	; if there are still blocks left to be handled, branch
		add	currPieceX,#8		; otherwise, all has checked out, and the block can move right

TetrChkBmpR_REND:
		popw	rr4
		popw	rr2
		pop	r0
		
TetrChkBmpR_END:
		ret
;----------------------------------------------------------------------------
Tetr_ChkBound:
		movw	rr2,#currPieceLyt
		mov	r4,#4

Chk_LWall:
		; ---- X CHECKS ----
		mov	r0,0(rr2)		; get the current block's X displacement
		add	r0,currPieceX		; add the Tetrimino's base X pos to the displacement
		mov	r1,r0	

		cmp	r0,#43			; is the piece within the wall?
		br	uge,Chk_RWall		; if not, branch
		sub	r1,#43
		sub	currPieceX,r1
		
Chk_RWall:
		cmp	r0,#115		; is the piece within the right wall?
		br	ule,Chk_Floor		; if not, branch
		sub	r1,#115
		sub	currPieceX,r1
		
Chk_Floor:
		; ---- Y CHECKS ----
		mov	r0,1(rr2)		; get the current block's X displacement
		add	r0,currPieceY		; add the Tetrimino's base X pos to the displacement
		mov	r1,r0
		cmp	r0,#152
		br	ult,Chk_NxtPce
		sub	r1,#152
		sub	currPieceY,r1
		mov	currPiecePlce,#1	; set the placement flag
		
Chk_NxtPce:
		addw	rr2,#2
		dec	r4
		br	nz,Chk_LWall
		ret
;----------------------------------------------------------------------------
Tetr_Grav:
		cmp	currPieceY,#152		; is the block on the floor?
		br	uge,TetrGrav_END	; if so, don't bother trying to handle gravity

		; check beneath the block to see if falling is even possible
		mov	r6,#4
		movw	rr2,#currPieceLyt

TetrGrav_Blk:
		movw	rr4,#playfieldMap	; load the playfield map into rr4

		mov	r0,1(rr2)		; get the current block's Y displacement		
		add	r0,currPieceY		; add the Y position
		srl	r0
		srl	r0
		srl	r0
		mov	r1,r0
		mov	r0,#0
		mult	rr0,#5
		addw	rr4,rr0			; add the Y displacement to the playfield map address
		
		mov	r0,0(rr2)		; get the current blocks' X displacement
		add	r0,currPieceX		; add the X position
		sub	r0,#43			; subtract the wall offset, getting the raw position
		srl	r0
		srl	r0
		srl	r0
		push	r0
		srl	r0
		mov	r1,r0
		mov	r0,#0
		addw	rr4,rr0
		pop	r0	
		mov	r1,5(rr4)		
		and	r0,#1
		cmp	r0,#0			; is the block pos even or odd?
		br	eq,TetrGrav_Read	; if even, branch
		and	r1,#7
		br	TetrGrav_Cmp
		
TetrGrav_Read:
		swap	r1
		and	r1,#7
		
TetrGrav_Cmp:
		cmp	r1,#7			; is the block underneath blank?
		br	ne,TetrGrav_Place	; if not, branch
		addw	rr2,#2
		dec	r6
		br	nz,TetrGrav_Blk
		
		; automatically falling
		movw	rr0,gravFactor
		addw	currPieceGrav,rr0
		cmp	currPieceGrav,#1
		br	ult,TetrGrav_END
		mov	r1,currPieceGrav
		sll	r1
		sll	r1
		sll	r1
		add	currPieceY,r1		; UNCOMMENT TO REENABLE GRAVITY AFTER TESTING
		mov	currPieceGrav,#0

TetrGrav_END:
		ret
		
TetrGrav_Place:
		mov	currPiecePlce,#1	; set the placement flag
		ret
;----------------------------------------------------------------------------
Tetr_PlacePiece:
		cmp	currPiecePlce,#0	; should the current Tetrimino be placed?
		jmp	eq,TetrPlcPc_END	; if not, branch
		mov	currPiecePlce,#0	; clear the placement flag

		pushw	rr2
		pushw	rr4
		
		mov	r6,#4
		movw	rr2,#currPieceLyt	; load the current Tetrimino layout into rr2

TetrPlcPc_Blk:		
		movw	rr4,#playfieldMap	; load the playfield map into rr4

		mov	r0,1(rr2)		; get the current block's Y displacement		
		add	r0,currPieceY		; add the Y position
		srl	r0
		srl	r0
		srl	r0
		mov	r1,r0
		mov	r0,#0
		mult	rr0,#5
		addw	rr4,rr0			; add the Y displacement to the playfield map address
		
		mov	r0,0(rr2)		; get the current blocks' X displacement
		add	r0,currPieceX		; add the X position
		sub	r0,#43			; subtract the wall offset, getting the raw position
		srl	r0
		srl	r0
		srl	r0
		push	r0
		srl	r0
		mov	r1,r0
		mov	r0,#0
		addw	rr4,rr0
		pop	r0
		
		mov	r7,tetrisPieces
		swap	r7
		and	r7,#7				

		mov	r1,0(rr4)
		
		and	r0,#1
		cmp	r0,#0			; is the block pos even or odd?
		br	eq,TetrPlcPc_Read	; if even, branch

		and	r1,#070h
		or	r1,r7

		br	TetrPlcPc_Nxt
		
TetrPlcPc_Read:
		and	r1,#07h
		swap	r7
		or	r1,r7

TetrPlcPc_Nxt:
		mov	0(rr4),r1
		addw	rr2,#2
		dec	r6
		br	nz,TetrPlcPc_Blk	; if there are still blocks left to be handled, branch

		mov	currPieceX,#75		; TEST X
		mov	currPieceY,#40		; TEST Y	
		
		movw	gravFactor,#20

		mov	r0,tetrisPieces
		mov	r1,tetrisPieces+1
		swap	r0
		swap	r1
		and	r0,#070h
		and	r1,#7
		or	r0,r1
		mov	tetrisPieces,r0
		mov	r1,tetrisPieces+1
		swap	r1
		and	r1,#070h
		call	RNGenerator		; fourth tetrimino
		mov	r0,pieceRNG
		and	r0,#7
		cmp	r0,#7
		br	ne,TetrPlcPc_ntBlnk
		dec	r0
		
TetrPlcPc_ntBlnk:
		or	r1,r0
		mov	tetrisPieces+1,r1
		
		mov	r0,tetrisPieces
		swap	r0
		and	r0,#7
		call	GetTPLayout
		
		mov	scoreAdd+2,#10h
		call	Update_Score
		
TetrPlcPc_REND:
		popw	rr4
		popw	rr2

TetrPlcPc_END:		
		ret
;============================================================================
		end
;============================================================================