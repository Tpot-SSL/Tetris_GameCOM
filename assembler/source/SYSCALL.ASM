    title   System Call
	type	8521
		
    program

System_Call     equ     20f1h
sp_control      equ     0a8h

    global          FBDrawGraphic
    global          Fi_patt
    global          disable_pause,enable_pause
	global			Disp_setup
    global          Dsp_ch
    global          FBFillColor
    global          Blk_rev
	global			Blk_cls
	global			FBDrawLineV
	global			FBDrawLineH
    global          clear_A
    global          Select_mode
    global          FBFillColorRect
	global			IOInputScan
	global			CTRL_KBD
	global			SET_TMR
	global			CTRL_TMR

    global          Switch_bank
    global          MemoryBlkReq
	global			Check_Timer
	global			Delay_Timer

    global  		Active_page_B
    global  		Active_page_A
	global			FBDrawGraphic2
	global			Swap_page
	
	global			SysKeyHandler
	global			quit_box
    global  		Return_line
	global			enable_timeout
	global			disable_timeout
	global			restart_timeout

Output_scan:
	pushw	rr6
	mov		r7,#7ah
	jmp		System_Call

Return_line:
	pushw	rr6
	mov		r7,#7bh
	jmp		System_Call

FBFillColorRect:
	pushw   rr6
	mov     r7,#2eh
	jmp		System_Call
Disp_setup:
	pushw	rr6
	mov		r7,#0
	jmp		System_Call
Dsp_ch:
    pushw   rr6
    mov     r7,#1
    jmp		System_Call
FBFillColor:
	pushw	rr6
	mov		r7,#1bh
	jmp		System_Call

Fi_patt:
    pushw   rr6
    mov     r7,#1ch
    jmp		System_Call

FBDrawGraphic:
	pushw   rr6
	mov     r7,#1dh
	jmp		System_Call

set_line_color:
	pushw	rr6
	mov		r7,#21h
	jmp		System_Call
Blk_rev:
    pushw   rr6
    mov     r7,#22h
    jmp		System_Call
Blk_cls:
	pushw	rr6
	mov		r7,#23h

FBDrawLineV:
	pushw	rr6
	mov		r7,#26h
	jmp		System_Call
FBDrawLineH:
	pushw	rr6
	mov		r7,#27h
	jmp		System_Call
clear_A:
    pushw   rr6
    mov     r7,#28h
    jmp		System_Call

Select_mode:
	pushw   rr6
	mov     r7,#2ch
	jmp		System_Call

IOInputScan:
	pushw	rr6
	mov		r7,#2fh
	jmp		System_Call
CTRL_KBD:
	pushw	rr6
	mov		r7,#30h
	jmp		System_Call
SET_TMR:
	pushw	rr6
	mov		r7,#31h
	jmp		System_Call
CTRL_TMR:
	pushw	rr6
	mov		r7,#32h

Switch_bank:
   pushw   rr6
   mov     r7,#45h
   jmp		System_Call

MemoryBlkReq:
	pushw	rr6
	mov		r7,#4ch
	jmp		System_Call

Check_Timer:
	pushw	rr6
	mov		r7,#50h
	jmp		System_Call
Delay_Timer:
	pushw	rr6
	mov		r7,#51h
Active_page_B:
	pushw	rr6
	mov		r7,#54h
	jmp		System_Call
Active_page_A:
	pushw	rr6
	mov		r7,#55h
	jmp		System_Call
FBDrawGraphic2:
	pushw	rr6
	mov		r7,#56h
	jmp		System_Call

Swap_page:
	pushw	rr6
	mov		r7,#57h
	jmp		System_Call

Blk_mov_2:
	pushw   rr6
	mov     r7,#58h
	jmp		System_Call

SysKeyHandler:
	pushw	rr6
	mov		r7,#78h
	jmp		System_Call	

quit_box:
	pushw	rr6
	mov		r7,#79h
	jmp		System_Call

enable_timeout:
;        pushw   rr6
;        mov     r7,#7ch
;        jmp		System_Call
        bclr    sp_control,#5           ;enable time_out
        ret

disable_timeout:
;        pushw   rr6
;        mov     r7,#7dh
;        jmp		System_Call
        bset    sp_control,#5           ;disable time_out
        ret

restart_timeout:
	pushw	rr6
	mov		r7,#7fh
	jmp		System_Call
	
enable_pause:
	pushw	rr6
	mov		r7,#82h
	jmp		System_Call	
	
disable_pause:
	pushw	rr6
	mov		r7,#83h
	jmp		System_Call	

FBDrawGraphicF:
	push	r0
	mov	r0,fadeStep		; copy the current fade step to r0
	cmp	r0,#127
	br	ule,FBFadeGraphicC
	cmp	r0,#159
	br	ule,FBFadeGraphic2
	cmp	r0,#191
	br	ule,FBFadeGraphic3
	pop	r0
	; fill with black
	mov	r8,#3
	jmp	FBFillColor		; fill the screen with black		

FBFadeGraphic3:
	inc	r14
FBFadeGraphic2:	
	inc	r14
	
FBFadeGraphicC:
	pop	r0
        pushw   rr6
        mov     r7,#1dh
        jmp	System_Call

	end

