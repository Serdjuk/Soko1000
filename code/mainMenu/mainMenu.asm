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

	ld	hl,#5870
	ld	b,14
	ld	a,%01110000
	call	RENDER.paint_attr_line

	ld	hl,#58B0
	ld	b,14
	ld	a,%01110000
	call	RENDER.paint_attr_line

	ld	hl,#58F0
	ld	b,14
	ld	a,%01110000
	call	RENDER.paint_attr_line


	ld	hl,#5930
	ld	b,14
	ld	a,%01110000
	call	RENDER.paint_attr_line




.loop:

	ld	a,(DATA.growing_text_is_animate)
	or	a
	push	af
	call	nz,RENDER.growing_text
	pop	af
	call	z,change_level_author_name

	LOOP	.loop

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