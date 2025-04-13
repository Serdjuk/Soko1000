	module	GAME_MENU

SCR_ADDR:	equ	#4082	
WIDTH:		equ	20
HEIGHT:		equ	14

init:
	ld	hl,SCR_ADDR + 33
	ld	bc,(WIDTH - 1) + (HEIGHT - 1)  *256
	xor	a
	call	RENDER.fill_scr_area

	ld	de,SCR_ADDR
	ld	bc,WIDTH + HEIGHT * 256
	ld	hl,1 + %01111001 * 256
	call	RENDER.draw_frame

	call	print_text


loop:
	call	INPUT.pressed_level_menu
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
	ld	hl,TEXT.text_smooth_motion
	ld	de,SCR_ADDR + 65 + WIDTH - 2 - 6
	call	RENDER.draw_word


	ret

	endmodule