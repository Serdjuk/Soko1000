	module	LEVEL_SELECTION


init:
	xor	a
	call	RENDER.clear_attributes
	call	RENDER.clear_screen

	call	draw_world_indices
	call	draw_level_indices
	call	draw_labels


	ld	a,3
	call	RENDER.clear_attributes
	call	paint_level_indices


.loop:
	ei
	halt

	call	move
	jr	.loop

draw_cursor:
	ld	hl,(DATA.cursor_table_addr)
	ld	a,(hl)
	inc	hl
	ld	h,(hl)
	ld	l,a
	ld	b,3
	call	RENDER.clear_paper_level_cursor
	ld	a,(DATA.level_index)
	rlca
	add 	low VAR.level_indices_attr_addr
	ld 	l,a
	adc 	high VAR.level_indices_attr_addr
	sub 	l
	ld 	h,a
	ld	(DATA.cursor_table_addr),hl
	ld	a,(hl)
	inc	hl
	ld	h,(hl)
	ld	l,a
	ld	b,3
	ld	c,6 << 3
	call	RENDER.paint_paper_level_cursor
	ret

input:
	call	INPUT.keyListener
	cp	SPACE
	jr	z,.swap_selection
	cp	ENTER
	ret	nz
					; start level
	

	ret	
.swap_selection:
	ld	a,(DATA.is_world_selection_active)
	xor	1
	ld	(DATA.is_world_selection_active),a
	ret

move:
	ld	a,(DATA.is_world_selection_active)
	or	a
	jr	z,move_world_cursor
	jr	move_level_cursor

move_world_cursor:
	call	INPUT.keyListener
	ld	hl,VAR.key_binding + 2
	cp	(hl)
	inc	hl
	jr	z,.left
	cp	(hl)
	inc	hl
	jr	z,.right
	ret
.right:
	ld	a,(DATA.world_index)
	inc	a
	cp	MAX_WORLDS
	jr	c,.set_new_index
	xor	a
.set_new_index:
	ld	(DATA.world_index),a
	ret
.left:
	ld	a,(DATA.world_index)
	sub	1
	jr	nc,.set_new_index
	ld	a,MAX_WORLDS - 1
	jr	.set_new_index


move_level_cursor:
	call	INPUT.keyListener
	ld	hl,VAR.key_binding
	cp	(hl)
	inc	hl
	jr	z,.up
	cp	(hl)
	inc	hl
	jr	z,.down
	cp	(hl)
	inc	hl
	jr	z,.left
	cp	(hl)
	inc	hl
	jr	z,.right
	ret
.up:
	ld	a,(DATA.level_index)
	sub	8
	jr	nc,.set_new_index
	and	7
	add	MAX_LEVELS - 4
	cp	MAX_LEVELS
	jr	c,.set_new_index
	sub	8
	jr	.set_new_index
.down:
	ld	a,(DATA.level_index)
	add	8
	cp	MAX_LEVELS
	jr	c,.set_new_index
	and	7
	jr	.set_new_index
.right:

	ld	a,(DATA.level_index)
	inc	a
	cp	MAX_LEVELS
	jr	c,.set_new_index
	xor	a
.set_new_index:
	ld	(DATA.level_index),a
	ret
.left:
	ld	a,(DATA.level_index)
	sub	1
	jr	nc,.set_new_index
	ld	a,MAX_LEVELS - 1
	jr	.set_new_index

draw_world_indices:
	ld	de,#4083
	ld	hl,1
	ld	b,10
.loop:
	push	bc
	push	de
	push	hl

	push	de
	ld	de,DATA.digital_value_buffer
	call	UTILS.num2dec.tenths	; DE - location of ASCII string
	dec	de
	dec	de
	pop	hl			; screen address
	ex	de,hl
	call	RENDER.draw_word

	pop	hl
	inc	l
	pop	de
	inc	e
	inc	e
	inc	e
	pop	bc
	djnz	.loop
	ret
draw_level_indices:

	ld	de,#4801
	ld	hl,1
	ld	b,12
.loop:
	push	bc
	push	de
	ld	b,8
	call	.row
	pop	de
	call	UTILS.down_de_symbol
	pop	bc
	djnz	.loop
	;	last 4
	ld	de,#5081
	ld	b,4
.row:
	push	bc
	push	hl
	push	de
	
	push	de
	ld	de,DATA.digital_value_buffer
	call	UTILS.num2dec.hundredths; DE - location of ASCII string
	dec	de
	dec	de
	dec	de
	pop	hl			; screen address
	ex	de,hl
	call	RENDER.draw_word
	pop	de
	inc	e
	inc	e
	inc	e
	inc	e
	pop	hl
	inc	hl
	pop	bc
	djnz	.row
	ret

draw_labels:
	ld	hl,TEXT.text_world_label
	ld	de,#4060
	call	RENDER.draw_word

	ld	hl,TEXT.text_level_label
	ld	de,#40e0
	call	RENDER.draw_word

	ret
paint_level_indices:
	ret

switch_selection_mode:
	ret


	endmodule