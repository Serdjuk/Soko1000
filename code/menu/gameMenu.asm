	module	GAME_MENU

SCR_ADDR:	equ	#4082	
WIDTH:		equ	20
HEIGHT:		equ	9

init:
	ld	hl,SCR_ADDR + 33
	ld	bc,(WIDTH - 1) + (HEIGHT - 1)  *256
	xor	a
	call	RENDER.fill_scr_area

	ld	de,SCR_ADDR
	ld	bc,WIDTH + HEIGHT * 256
	ld	hl,2 + %01111001 * 256
	call	RENDER.draw_frame

	call	print_text


loop:
	ld	c,'I'
	call	INPUT.pressed_key
	jr	z,exit

	LOOP	loop

exit:
	call	GAME.clear_play_area
	call	RENDER.draw_level
	ld	bc,24 + 24 * 256
	ld	hl,#5800
	ld	a,(DATA.level_color)
	call	RENDER.fill_attr_area
	LOOP	GAME.start


print_text:
	ld	ixl,FONT_ITALIC_HALF_BOLD
	ld	hl,TEXT.text_smooth_motion
	ld	de,SCR_ADDR + 66 + WIDTH - 4 - 6
	call	RENDER.draw_word
	ld	hl,TEXT.text_quit
	ld	de,SCR_ADDR + 98 + WIDTH - 4 - 4
	call	RENDER.draw_word
	ld	hl,TEXT.text_restart
	ld	de,#4804 + WIDTH - 4 - 7
	call	RENDER.draw_word
	ld	hl,TEXT.text_color
	ld	de,#4804 + 32 + WIDTH - 4 - 5
	call	RENDER.draw_word
	ld	hl,TEXT.text_close
	ld	de,#4804 + 32 + 32 + WIDTH - 4 - 5
	call	RENDER.draw_word

	; keys:
	ld	ixl,FONT_BOLD
	ld	a,'M'
	ld	de,SCR_ADDR + 66
	call	RENDER.draw_char
	ld	a,'E'
	ld	de,SCR_ADDR + 98
	call	RENDER.draw_char
	ld	a,'R'
	ld	de,#4804
	call	RENDER.draw_char
	ld	a,'C'
	ld	de,#4804 + 32
	call	RENDER.draw_char
	ld	a,'I'
	ld	de,#4804 + 32 + 32
	call	RENDER.draw_char


	ret


; + A - confirm index: (CONFIRM_EXIT_ID, CONFIRM_RESTART_ID)
; + HL - callback by YES
confirmation_window:
	push	hl
	push	af
	ld	hl,SCR_ADDR + 33
	ld	bc,(WIDTH) + (HEIGHT - 2)  *256
	xor	a
	call	RENDER.fill_scr_area

	ld	de,SCR_ADDR
	ld	bc,WIDTH + 1 + (HEIGHT - 1) * 256
	ld	hl,2 + %01111001 * 256
	call	RENDER.draw_frame

	ld	hl,TEXT.text_confirm_exit
	ld	de,#40C3
	pop	af
	rrca
	jr	c,.another_text
	ld	hl,TEXT.text_confirm_restart
	ld	de,#40C5
.another_text:
	ld	ixl,FONT_ITALIC_HALF_BOLD
	call	RENDER.draw_word
	ld	ixl,FONT_NORMAL
	ld	hl,TEXT.text_yes
	ld	de,#4825
	ld	a,%01111100
	call	paint_symbol
	call	RENDER.draw_word
	ld	hl,TEXT.text_no
	ld	de,#4825 + 13
	ld	a,%01111010
	call	paint_symbol
	call	RENDER.draw_word

.wait:
	ei
	halt	
	call	INPUT.keyListener
	ld	c,'Y'
	call	INPUT.pressed_key
	ret	z
	ld	c,'N'
	call	INPUT.pressed_key
	jr	z,.cancel
	jr	.wait
.cancel:
	pop	hl
	jp	exit
; + A - color
; + DE - screen address
paint_symbol:
	push	de
	push	af
	call	UTILS.scr_to_attr_de
	pop	af
	ld	(de),a
	pop	de
	ret
	endmodule