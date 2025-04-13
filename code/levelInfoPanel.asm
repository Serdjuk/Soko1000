	module	LEVEL_INFO_PANEL
; + 
init:


	ld	hl,TEXT.text_world_label
	ld	de,#4039
	call	RENDER.draw_word

	ld	hl,TEXT.text_level_label
	ld	de,#4079
	call	RENDER.draw_word


	ld	hl,TEXT.text_crates_label
	ld	de,#40f9
	call	RENDER.draw_word

	ld	hl,TEXT.text_steps_label
	ld	de,#4839
	call	RENDER.draw_word

	ld	hl,TEXT.text_level_menu
	ld	de,#50D9
	call	RENDER.draw_word



	ld	a,(DATA.LEVEL.crates)
	ld	de,#481E
	call	draw_one_digit



	ld	a,(DATA.world_index)
	inc	a
	ld	de,DATA.digital_value_buffer
	ld	l,a
	ld	h,0
	push	de
	call	UTILS.num2dec.tenths
	pop	hl
	ld	de,#405D
	call	RENDER.draw_word

	ld	a,(DATA.level_index)
	inc	a
	ld	l,a
	ld	h,0
	ld	de,DATA.digital_value_buffer
	push	de
	call	UTILS.num2dec.hundredths
	pop	hl
	ld	de,#409C
	call	RENDER.draw_word


	call	draw_player_steps_value

	ret


draw_player_steps_value:
	ld	hl,(DATA.player_steps)
	ld	de,DATA.digital_value_buffer
	push	de
	call	UTILS.num2dec
	pop	hl
	ld	de,#485A
	jp	RENDER.draw_word


; + A - value
; + DE - screen address
draw_one_digit:
	push	de
	ld	l,a
	ld	h,0
	ld	de,DATA.digital_value_buffer
	push	de
	ld	b,#FF
	call	UTILS.num2dec.tenths + 6
	pop	de
	ld	a,(de)
	pop	de
	jp	RENDER.draw_char


	endmodule
