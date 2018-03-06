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
		call	IOInputScan		; use the system call to read the current inputs
		mov	playerInput,r0		; store the input to RAM
		call	IOInputScan
		mov	r1,playerInput
		cmp	r0,r1
		br	eq,ReadInput
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
; Subroutine to render a tetris piece
; ===========================================================================
Render_TP:
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
		end
; ===========================================================================	