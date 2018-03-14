		data	
;============================================================================
; Zero Page Ram (0xBE-0xFF)
;----------------------------------------------------------------------------
		org	0BEh
prevVtick	defs	1	; the previous V-Int tick

		; 0000 XXXX XXXX XXXX
		;      DoCB AmpM RLDU
playerPress	defs	2	; the player's pressed buttons for the frame
playerHeld	defs	2	; the player's held buttons for the frame

		defs	1
fadeStep	defs	1	; fading step
gameState	defs	1	; gameState
nextGState	defs	1	; next gameState
currPage	defs	1	; current rendering page
UIupdFlags	defs	1	; UI/rendering update flags

tetrisPieces	defs	2	; the 4 generated tetris pieces (01110222 03330444)
pieceRNG	defs	1	; randomly generated number for tetris pieces
currPieceLyt	defs	8	; current tetris piece layout
currPieceX	defs	1	; current tetris piece X-coordinate
currPieceY	defs	1	; current tetris piece Y-coordinate
currPieceGrav	defs	2	; current piece gravity
gravFactor	defs	2	; the gravity factor
currPiecePlce	defs	1	; current tetris piece placement flag/timer

gameType	defs	1	; the game's mode
gameLevel	defs	1	; the current game's level
linesClr	defs	2	; the kept count of lines cleared in the game
gameScore	defs	3	; the game's score (capped at 999,999)
scoreAdd	defs	3	; amount to add to the game's score
	
; Check to make sure that the space within zero page RAM hasn't been exceeded
chk_FF:
            if      chk_FF .gt. 0FFh
            error 	Too much data in zero page ram
            endif
;============================================================================
; Non-zero Page Ram (0x208-0x37F)
;----------------------------------------------------------------------------
		org	0208h
playfieldMap	defs	100	; the game field's placement map
clrLineMap	defs	20	; mapout of the cleared lines to handle, when needed
	
; Check to make sure that the space within zero page RAM hasn't been exceeded
chk_37F:
            if      chk_37F .gt. 037Fh
            error 	Too much data in non-zero page ram
            endif
;============================================================================  
; User Input Equates
;----------------------------------------------------------------------------
; For touch inputs...
; Value = Row*13+Column+1
; EXAMPLE: Top Left = 0x01, Bottom Right = 0x82

inputUp		equ	001h	; joypad up
inputDown	equ	002h	; joypad down
inputLeft	equ	004h	; joypad left
inputRight	equ	008h	; joypad right

inputMenu	equ	010h	; Menu button
inputSound	equ	040h	; Sound button
inputPause	equ	020h	; Pause button

inputA		equ	080h	; A button
inputB		equ	001h	; B button
inputC		equ	002h	; C button
inputD		equ	008h	; D button
;============================================================================