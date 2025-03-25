	module	LEVEL_INFO_SCREEN

init:
	ld	hl,100
	ld	(DATA.timer),hl
	ld	hl,TEXT.text_world_label
	ld	de,#484B
	call	RENDER.draw_word
	ld	a,(DATA.world_index)
	inc	a
	ld	l,a
	ld	h,0
	ld	de,DATA.digital_value_buffer
	call	UTILS.num2dec.tenths
	dec	de
	dec	de
	ld	hl,#484B + 8
	ex	de,hl
	call	RENDER.draw_word

	ld	hl,TEXT.text_level_label
	ld	de,#48CB
	call	RENDER.draw_word
	ld	a,(DATA.level_index)
	inc	a
	ld	l,a
	ld	h,0
	ld	de,DATA.digital_value_buffer
	call	UTILS.num2dec.hundredths
	dec	de
	dec	de
	dec	de
	ld	hl,#48CB + 7
	ex	de,hl
	call	RENDER.draw_word
	call	RENDER.fade_in
.loop:
	call	UTILS.wait_any_key
	jr	nz,to_game
	ld	hl,(DATA.timer)
	dec	hl
	ld	a,h
	or	l
	jr	z,to_game
	ld	(DATA.timer),hl
	LOOP	.loop
to_game:
	call	RENDER.fade_out
	call	RENDER.clear_screen
	LOOP	GAME.init

	endmodule