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
		; $D
		; P0
		;7F = 0111 1111 = A
		;BF = 1011 1111 = mute
		;DF = 1101 1111 = pause
		;EF = 1110 1111 = menu
		;F7 = 1111 0111 = right
		;FB = 1111 1011 = left
		;FD = 1111 1101 = down
		;FE = 1111 1110 = up
		; P1
		;FD = 1111 1101 = C
		;FE = 1111 1110 = B
		mov	015h,#0FFh
		mov	016h,#07Fh
		mov	r3,#10
waitLoop:
		nop
		nop
		nop
		dbnz	r3,waitLoop
		mov	r0,014h			; read P0 into r0
		mov	r1,015h			; read P1 into r1
		or	r1,#0FCh		; filter the relevant bits for P1
		
		; $E
		; P0
		;FD = 1111 1101 = D
		;FE = 1111 1110 = on/off
		mov	015h,#0FFh
		mov	016h,#0FFh
		mov	r3,#10
waitLoop2:
		nop
		nop
		nop
		dbnz	r3,waitLoop2
		mov	r2,014h			; read P0 into r0
		or	r2,#0FCh

		neg	r0
		neg	r1
		neg	r2
		sll	r2
		sll	r2
		or	r2,r1
		
		mov	r3,playerHeld
		mov	r4,playerHeld+1
		
		mov	playerHeld,r2
		mov	playerHeld+1,r0
		
		xor	r2,r3
		xor	r0,r4
		
		and	r2,playerHeld
		and	r0,playerHeld+1
		
		mov	playerPress,r2
		mov	playerPress+1,r0		
		
		; 0000 XXXX XXXX XXXX
		;      DoCB AmpM RLDU
		
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
StrCharY        equ     224
StrCharBank     equ     39
StrCharWid      equ     6

FBDrawChar:
		mov	r11,r10
		mov	r10,#0
		mult	rr10,#StrCharWid
		mov	r10,r11
		mov	r11,#StrCharY
		mov	r12,#StrCharWid
		mov	r13,#StrCharWid
		mov	r14,#StrCharBank
		mov	r15,#01h
		cmp	currPage,#1
		br	eq,FBDrawChar_1
		add	r15,#02h
FBDrawChar_1:
		call	FBDrawGraphic		
		cmp	r0,#36		; is the character a space?
		br	eq,FBDrawChar_END ; if so, dont do the extra XORing
		add	r11,#12
		mov	r15,#09h
		cmp	currPage,#1
		br	eq,FBDrawChar_2
		add	r15,#02h
FBDrawChar_2:
		call	FBDrawGraphic			
FBDrawChar_END:
		ret
; ===========================================================================	
; Subroutine to write a string on screen
; Input:
; rr0 = String's address
; r8 = String's X-position
; r9 = String's Y-position
; ===========================================================================
FBDrawString:
		
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
		mov	r0,#36
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
		call	FBDrawChar	; otherwise, draw the character

DrwStr_NxtChr:
		add	r8,#6		; increase the X-position for the next character
		br	DrwStr_Chr
		
DrwStr_END:		
		ret
; ===========================================================================	
; Subroutine to generate a random number
; ===========================================================================
RNGenerator:
		push	r0			; store r0 onto the stack
		mov	r0,pieceRNG		; grab the previous RNG seed
		add	r0,prevVtick		; add the previous vertical blank tick to the seed
		push	r1			; store r1 onto the stack
		mov	r1,tetrisPieces		; copy the high byte of the current tetris pieces to r1
		rl	r1			; roll the current piece around to the first 3 bits
		rl	r1
		rl	r1
		and	r1,#3			; mask out the current piece
		add	r0,r1			; add this piece to the seed
		pop	r1			; restore r1 from the stack
		sub	r0,#1			; decrement the seed
		mov	pieceRNG,r0		; store the newly generated seed
		pop	r0			; restore r0 from the stack
		ret				; return
; ===========================================================================	
; Subroutine to init a tetris piece layout
; Usage:
; r0 = Piece ID to use
; ===========================================================================
GetTPLayout:
		pushw	rr2			; copy rr2 onto the stack
		movw	rr2,#TP_LayoutData	; load the address for the Tetrimino layout data into rr2
		sll	r0
		sll	r0
		sll	r0			; ...multiply the Tetrimino ID by 8
		
		; prepare for proper word add
		mov	r1,r0			; copy this to r1
		mov	r0,#0			; clear r0
		addw	rr2,rr0			; add the ID to the layout data address, getting the right layout for the current ID

		movw	rr4,#currPieceLyt	; load the piece layout RAM into rr4
		mov	r1,#8
GetTPLayout_Copy:
		mov	r0,(rr2)+
		mov	(rr4)+,r0		
		dec	r1			; decrement the loop counter
		br	nz,GetTPLayout_Copy	; if there is data left, loop

		popw	rr2			; restore rr2 from the stack
		ret
; ===========================================================================	
; Subroutine to rotate a tetris piece 90 degrees
; ===========================================================================
Rotate_TP:
		; CLOCKWISE 90 FOR NOW
		pushw	rr2
		movw	rr2,#currPieceLyt	; load the address for the Tetrimino layout data into rr2
		mov	r4,#4

RotateTP_Rot:
		mov	r0,(rr2)+		; get this block's X disp
		mov	r1,0(rr2)		; get this block's Y disp
		neg	r1
		mov	0(rr2),r0
		mov	-(rr2),r1
;		neg	r0
;		mov	0(rr2),r0
;		mov	-(rr2),r1
		addw	rr2,#2
		dec	r4
		br	nz,RotateTP_Rot

		popw	rr2
		ret
; ===========================================================================	
; Subroutine to render a tetris piece
; ===========================================================================
Render_TP:
		pushw	rr2
		movw	rr2,#currPieceLyt	; load the address for the Tetrimino layout data into rr2
		mov	r0,tetrisPieces
		swap	r0
		and	r0,#7
		sll	r0			; ...
		sll	r0			; ...
		sll	r0			; ...multiply the Tetrimino ID by 8
		mov	r10,r0
		mov	r1,#4			; set loop counter for 4 blocks

TP_NextBlock:
		mov	r0,(rr2)+		; get the current block's X displacement
		mov	r8,r0
		add	r8,currPieceX
		mov	r0,(rr2)+		; get the current block's Y displacement
		mov	r9,r0
		add	r9,currPieceY
		
		mov	r11,#248		; Tetrimino tiles starting Y pos in bank
		mov	r12,#8			; 8 wide tile
		mov	r13,#8			; 8 tall tile
		mov	r14,#39			; bank #
		mov	r15,#0			; draw in composite mode
		cmp	currPage,#1
		br	eq,TP_DrawBlock
		add	r15,#02h
TP_DrawBlock:
		call	FBDrawGraphic
		dec	r1			; decrement the loop counter
		br	nz,TP_NextBlock		; if there are still blocks to be drawn, branch

		popw	rr2		
		ret
; ---------------------------------------------------------------------------
; TETRIMINO LAYOUT DATA
; Each Tetrimino gets 8 bytes, two each of its blocks
; FORMAT: X-Pos Displacement, Y-Pos Displacement
; Keep each displacement a multiple of 8 (saves processing time)
TP_LayoutData:
		defb	0, -16			; 0 - I
		defb	0, -8
		defb	0, 0
		defb	0, 8
		
		defb	-8, 0			; 1 - T
		defb	0, 0
		defb	8, 0
		defb	0, -8
		
		defb	0, -8			; 2 - L
		defb	0, 0
		defb	0, 8
		defb	8, 8
		
		defb	0, -8			; 3 - J
		defb	0, 0
		defb	0, 8
		defb	-8, 8
		
		defb	-8, 0			; 4 - O
		defb	0, 0
		defb	0, 8
		defb	-8, 8
		
		defb	0, 0			; 5 - S
		defb	8, 0
		defb	-8, 8
		defb	0, 8
		
		defb	-8, 0			; 6 - Z
		defb	0, 0
		defb	0, 8
		defb	8, 8

		defb	0, 0			; 7 - blank
		defb	0, 0			; junk data
		defb	0, 0
		defb	0, 0
; ===========================================================================	
; Subroutine to render the playfield
; ===========================================================================
Render_Plyfld:
		pushw	rr2
		pushw	rr0

		movw	rr2,#playfieldMap	; load the address for the playfield map into rr2
		mov	r4,#5			; set X loop counter
		mov	r5,#20			; set Y loop counter
		mov	r8,#43			; set initial X drawing pos
		mov	r9,#0			; set initial Y drawing pos

RPF_NextBlocks:
		mov	r0,(rr2)+		; get two blocks from the map
		mov	r1,r0
		swap	r0
		and	r0,#7			; isolate the first block in r0
		and	r1,#7			; isolate the second block in r1
		sll	r0			; ...
		sll	r0			; ...
		sll	r0			; ...multiply the first block # by 8
		sll	r1			; ...
		sll	r1			; ...
		sll	r1			; ...multiply the second block # by 8

		mov	r10,r0
		mov	r11,#248		; Tetrimino tiles starting Y pos in bank
		mov	r12,#8			; 8 wide tile
		mov	r13,#8			; 8 tall tile
		mov	r14,#39			; bank #
		mov	r15,#0			; draw in composite mode
		cmp	currPage,#1
		br	eq,RPF_DrawBlock1
		add	r15,#02h
RPF_DrawBlock1:
		call	FBDrawGraphic
		
		mov	r10,r1
		add	r8,#8
		mov	r11,#248		; Tetrimino tiles starting Y pos in bank
		mov	r12,#8			; 8 wide tile
		mov	r13,#8			; 8 tall tile
		mov	r14,#39			; bank #
		mov	r15,#0			; draw in composite mode
		cmp	currPage,#1
		br	eq,RPF_DrawBlock2
		add	r15,#02h
RPF_DrawBlock2:
		call	FBDrawGraphic

		add	r8,#8			; go to the next two blocks in line
		dec	r4			; decrement the X loop counter
		br	nz,RPF_NextBlocks	; if there are still blocks to be drawn, branch
		mov	r8,#43			; reset the X drawing pos
		add	r9,#8			; go down a row
		mov	r4,#5			; reset X loop counter
		dec	r5			; decrement the Y loop counter
		br	nz,RPF_NextBlocks	; if there are still blocks to be drawn, branch

		popw	rr0
		popw	rr2		
		ret
; ===========================================================================	
; Subroutine to render the UI accordingly
; ===========================================================================		
Render_UI:
;		cmp	UIupdFlags,#0		; does the UI need to be updated at all?
;		br	eq,Render_UI_END	; if not, branch
;		mov	UIupdFlags,#0
		
		mov	r8,#123
		mov	r9,#0
		mov	r10,#0
		mov	r11,#0
		mov	r12,#77			    ; Horizontal size
		mov	r13,#160		    ; Vertical size
		mov	r14,#36			; Bank #
		mov	r15,#0			    ; Write mode
		cmp	currPage,#1
		br	eq,RndrUI_Field1
		add	r15,#02h
RndrUI_Field1:		
		call	FBDrawGraphic			; Render the background to Page A
		
		mov	r8,#0
		mov	r9,#0
		mov	r10,#200
		mov	r11,#0
		mov	r12,#43				; Horizontal size
		mov	r13,#160			; Vertical size
		mov	r14,#39				; Bank #
		mov	r15,#0				; Write mode
		cmp	currPage,#1
		br	eq,RndrUI_Field2
		add	r15,#02h
RndrUI_Field2:		
		call	FBDrawGraphic			; Render the background to Page A

		; render the current game-type
		mov	r8,#178
		mov	r9,#129
		mov	r10,gameType			; copy the current game-type to r0
		add	r10,#0Ah
		call	FBDrawChar
		
RndrUI_LinesClr:
		; render the total of lines cleared
		mov	r8,#6
		mov	r9,#120
		mov	r10,linesClr
		swap	r10
		and	r10,#0FH
		call	FBDrawChar
		add	r8,#6
		mov	r10,linesClr
		and	r10,#0FH
		call	FBDrawChar
		add	r8,#6
		mov	r10,linesClr+1
		swap	r10
		and	r10,#0FH
		call	FBDrawChar
		add	r8,#6
		mov	r10,linesClr+1
		and	r10,#0FH
		call	FBDrawChar		
		
RndrUI_Score:
		; render the score
		mov	r8,#150
		mov	r9,#145
		mov	r10,gameScore
		swap	r10
		and	r10,#0FH
		call	FBDrawChar
		add	r8,#6
		mov	r10,gameScore
		and	r10,#0FH
		call	FBDrawChar
		add	r8,#6
		mov	r10,gameScore+1
		swap	r10
		and	r10,#0FH
		call	FBDrawChar
		add	r8,#6
		mov	r10,gameScore+1
		and	r10,#0FH
		call	FBDrawChar
		add	r8,#6
		mov	r10,gameScore+2
		swap	r10
		and	r10,#0FH
		call	FBDrawChar
		add	r8,#6
		mov	r10,gameScore+2
		and	r10,#0FH
		call	FBDrawChar

Render_UI_END:
		ret
; ===========================================================================	
; Subroutine to handle adding to the game's score
; ===========================================================================
Update_Score:
		mov	r0,gameScore+2
		mov	r1,scoreAdd+2
		and	r0,#00Fh		
		and	r1,#00Fh		
		add	r0,r1
		cmp	r0,#00Ah		; has the current digit surpassed 10?
		br	ult,UpdScr_Dgt2		; if not, branch
		sub	r0,#00Ah
		add	gameScore+2,#010h

UpdScr_Dgt2:
		mov	r4,#0
		or	r4,r0
		mov	r0,gameScore+2
		mov	r1,scoreAdd+2
		and	r0,#0F0h		
		and	r1,#0F0h		
		add	r0,r1
		cmp	r0,#0A0h		; has the current digit surpassed 10?
		br	ult,UpdScr_Dgt3		; if not, branch
		sub	r0,#0A0h
		add	gameScore+1,#001h

UpdScr_Dgt3:		
		or	r4,r0
		mov	gameScore+2,r4
		
		mov	r0,gameScore+1
		mov	r1,scoreAdd+1
		and	r0,#00Fh		
		and	r1,#00Fh		
		add	r0,r1
		cmp	r0,#00Ah		; has the current digit surpassed 10?
		br	ult,UpdScr_Dgt4		; if not, branch
		sub	r0,#00Ah
		add	gameScore+1,#010h

UpdScr_Dgt4:		
		mov	r4,#0
		or	r4,r0
		mov	r0,gameScore+1
		mov	r1,scoreAdd+1
		and	r0,#0F0h		
		and	r1,#0F0h		
		add	r0,r1
		cmp	r0,#0A0h		; has the current digit surpassed 10?
		br	ult,UpdScr_Dgt5		; if not, branch
		sub	r0,#0A0h
		add	gameScore,#001h

UpdScr_Dgt5:		
		or	r4,r0
		mov	gameScore+1,r4
		
		mov	r0,gameScore
		mov	r1,scoreAdd
		and	r0,#00Fh		
		and	r1,#00Fh		
		add	r0,r1
		cmp	r0,#00Ah		; has the current digit surpassed 10?
		br	ult,UpdScr_Dgt6		; if not, branch
		sub	r0,#00Ah
		add	gameScore,#010h

UpdScr_Dgt6:		
		mov	r4,#0
		or	r4,r0
		mov	r0,gameScore
		mov	r1,scoreAdd
		and	r0,#0F0h		
		and	r1,#0F0h		
		add	r0,r1
		cmp	r0,#0A0h		; has the current digit surpassed 10?
		br	ult,UpdScr_END		; if not, branch

		; cap the score at 999,999
		mov	gameScore,#099h
		mov	gameScore+1,#099h
		mov	gameScore+2,#099h
		ret

UpdScr_END:		
		or	r4,r0
		mov	gameScore,r4	
		ret
; ===========================================================================
		end
; ===========================================================================	