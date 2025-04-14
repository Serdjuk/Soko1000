	module	MAIN_MENU

init:



	ld	a,100
	ld	(DATA.timer),a
	ld	hl,#5AA0
	ld	b,32
	ld	a,%01000111
	call	RENDER.paint_attr_line
	ld	a,%01001110
	ld	b,32
	call	RENDER.paint_attr_line
	ld	a,%01000111
	ld	b,32
	call	RENDER.paint_attr_line


	ld	hl,UTILS.char_addr.font_addr + 1
	inc	(hl)
	push	hl
	ld	hl,TEXT.text_level_authors
	ld	de,#50B3
	call	RENDER.draw_word
	pop	hl
	dec	(hl)

	ld	hl,#3C00 - 1
	ld	(UTILS.char_addr.font_addr + 1),hl
	ld	hl,TEXT.text_year
	ld	de,#50FC
	call	RENDER.draw_word
	ld	hl,#3C00
	ld	(UTILS.char_addr.font_addr + 1),hl


	ld	hl,#50E0
	ld	c,32
	ld	a,%01010101
	call	RENDER.fill_line
	ld	hl,#57A0
	ld	c,32
	ld	a,%01010101
	call	RENDER.fill_line

	; menu

	ld	hl,VAR.mm_moving_strings_frames
	ld	de,DATA.start_of_level_data
	ld	bc,VAR.mm_moves + 1 - VAR.mm_moving_strings_frames
	ldir



.loop:

	call	menu_flyout
	ld	a,(DATA.growing_text_is_animate)
	or	a
	push	af
	call	nz,RENDER.growing_text
	pop	af
	call	z,change_level_author_name
	LOOP	.loop


menu_flyout:
	ld	a,(DATA.start_of_level_data + VAR.mm_moves - VAR.mm_moving_strings_frames)
	dec	a
	ret	m
	ld	(DATA.start_of_level_data + VAR.mm_moves - VAR.mm_moving_strings_frames),a

	ld	hl,DATA.start_of_level_data
	ld	ix,DATA.start_of_level_data + (VAR.mm_moving_strings_scr_addrs - VAR.mm_moving_strings_frames)
	ld	b,3
.leading:
	push	bc
	push	hl
	ld	a,(hl)
	or	a
	push	af
	ld	de,fly_symbol_to_left.leading_attr
	call	z,fly_symbol_to_left
	pop	af
	sub	1
	adc	0
	pop	hl
	ld	(hl),a
	inc	hl
	inc	ix
	inc	ix
	pop	bc
	djnz	.leading

	ld	b,3
.secondary:
	push	bc
	push	hl
	ld	a,(hl)
	or	a
	push	af
	ld	de,fly_symbol_to_left.secondary_attr
	call	z,fly_symbol_to_left
	pop	af
	sub	1
	adc	0
	pop	hl
	ld	(hl),a
	inc	hl
	inc	ix
	inc	ix
	pop	bc
	djnz	.secondary
	ret

; + DE - callback address
fly_symbol_to_left:
	push	de
	ld	b,8
	ld	de,SPRITE.corner
	ld	l,(ix)
	ld	h,(ix + 1)
.next_line:
	ld	a,(de)
	ld	(hl),a
	inc	l
	ld	(hl),0
	dec	l
	inc	h
	inc	de
	djnz	.next_line
	dec	h
	call	UTILS.scr_to_attr_hl
	ret
.leading_attr:
	ld	(hl),%00000110
	inc	l
	ld	(hl),%00110001
	dec	(ix)
	ret
.secondary_attr:
	ld	(hl),%00110000
	inc	l
	ld	(hl),0
	dec	(ix)
	ret

change_level_author_name:
	ld	hl,AUTHORS.all

	ld	a,(DATA.timer)
	dec	a
	ld	(DATA.timer),a
	ret	nz
	inc	a
	ld	(DATA.timer),a
	push	hl
	call	clear_name
	pop	hl
	ret	nz
	ld	a,100
	ld	(DATA.timer),a

	ld	de,#50C1
	ld	(clear_name + 1),de
	call	UTILS.growing_text_char_data_generator

	ld	a,(hl)
	or	a
	jr	nz,.next
	ld	hl,AUTHORS.all
.next:
	ld	(change_level_author_name + 1),hl
	ret

clear_name:
	ld	hl,0
	ld	(hl),0
	ld	a,h
	push	hl
	pop	de
	inc	e
	ld	bc,30
	ldir	
	inc	a
	ld	(clear_name + 2),a
	and	7
	ret

	endmodule