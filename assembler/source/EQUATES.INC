		data	
;============================================================================
; Zero Page Ram (0xBE-0xFF)
;----------------------------------------------------------------------------
		org	0BEh
prevVtick	defs	1	; the previous V-Int tick
playerInput	defs	1	; the player's input for the frame
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
currPieceRot	defs	1	; current tetris piece rotation factor
	
; Check to make sure that the space within zero page RAM hasn't been exceeded
chk_FF:
            if      chk_FF .gt. 0FFh
            error 	Too much data in zero page ram
            endif
;============================================================================  
; User Input Equates
;----------------------------------------------------------------------------
; For touch inputs...
; Value = Row*13+Column+1
; EXAMPLE: Top Left = 0x01, Bottom Right = 0x82

inputUp		equ	083h	; joypad up
inputDown	equ	084h	; joypad down
inputLeft	equ	085h	; joypad left
inputRight	equ	086h	; joypad right

inputMenu	equ	087h	; Menu button
inputSound	equ	089h	; Sound button
inputPause	equ	08ah	; Pause button

inputA		equ	08bh	; A button
inputB		equ	08ch	; B button
inputC		equ	08dh	; C button
inputD		equ	08eh	; D button
;============================================================================