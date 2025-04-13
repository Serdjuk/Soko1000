	module	GAME_MENU

init:
	ld	hl,#40A3
	ld	bc,12 + 12  *256
	ld	a,#00
	call	RENDER.fill_scr_area

	ld	de,#4082
	ld	bc,13 + 13 * 256
	ld	hl,1 + %01111001 * 256
	call	RENDER.draw_frame
loop:
	call	INPUT.pressed_level_menu
	jr	z,exit

	LOOP	loop

exit:
	ld	bc,24 + 24 * 256
	ld	a,(DATA.level_color)
	ld	hl,#5800
	call	RENDER.fill_attr_area
	call	GAME.clear_play_area
	call	RENDER.draw_level
	LOOP	GAME.start

	endmodule