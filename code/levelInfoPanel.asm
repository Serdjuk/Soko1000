	module	LEVEL_INFO_PANEL
; + 
init:

	call	top_frame
	call	middle_frame
	call	bottom_frame





	ld	de,#4018
	ld	bc,8 + 6 * 256
	ld	hl,4 + %01001111 * 256
	call	RENDER.draw_frame


	ld	de,#4878
	ld	bc,8 + 4 * 256
	ld	hl,4 + %01001111 * 256
	call	RENDER.draw_frame


	ld	de,#50B8
	ld	bc,8 + 3 * 256
	ld	hl,4 + %01001111 * 256
	call	RENDER.draw_frame


	ret

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



top_frame:
	ld	ixl,FONT_ITALIC_HALF_BOLD
	ld	hl,TEXT.text_world_label
	ld	de,#4039
	call	RENDER.draw_word

	ld	hl,TEXT.text_level_label
	ld	de,#4079
	call	RENDER.draw_word


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

	ret

middle_frame:

	ld	hl,TEXT.text_crates_label
	ld	de,#4899
	call	RENDER.draw_word

	ld	a,(DATA.LEVEL.crates)
	ld	de,#48BE
	call	draw_one_digit

	ret

bottom_frame:
	ld	hl,TEXT.text_level_menu
	ld	de,#50D9
	call	RENDER.draw_word

	ret
	endmodule
