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

	call	show_info
	; call	swap_selection



	call	draw_world_cursor
	call	draw_level_cursor


.loop:
	ei
	halt

	call	move
	call	swap_mode
	
	LOOP	.loop


show_info:
	ld	de,#50E0
	ld	hl,TEXT.text_swap_label
	call	RENDER.draw_word
	ld	de,#50F1
	ld	hl,TEXT.text_start_label
	call	RENDER.draw_word

	ld	hl,#5AE0
	ld	b,#20
	ld	a,%01000111
	call	RENDER.draw_attr_line
	ld	hl,#5AE1
	ld	b,5
	ld	a,%01000100
	call	RENDER.draw_attr_line
	ld	hl,#5AF2
	ld	b,5
	ld	a,%01000100
	jp	RENDER.draw_attr_line

; + IX - cursor table address
; + DE - table address
; + A - index of world or level
; + B - attribute line length
draw_cursor:
	ld	l,(ix)
	ld	h,(ix + 1)
	push	bc
	push	af
	call	RENDER.clear_paper_level_cursor
	pop	af
	rlca
	add 	e
	ld 	l,a
	adc 	d
	sub 	l
	ld 	h,a
	ld	a,(hl)
	inc	hl
	ld	h,(hl)
	ld	l,a

	ld	(ix),l
	ld	(ix + 1),h
	pop	bc
	ld	c,6 << 3
	call	RENDER.paint_paper_level_cursor
	ret

swap_mode:
	call	INPUT.keyListener
	cp	SPACE
	jr	z,swap_selection
	cp	ENTER
	ret	nz
					; start level
	

	call	RENDER.fade_out
	call	RENDER.clear_screen
	; ld	a,6
	; call	RENDER.clear_attributes
	pop	af
	LOOP	LEVEL_INFO_SCREEN.init


draw_world_cursor:
	ld	a,(DATA.world_index)
	ld	ix,DATA.world_cursor_table_addr
	ld	de,VAR.world_indices_attr_addr
	ld	b,2
	jr	draw_cursor
draw_level_cursor:
	ld	a,(DATA.level_index)
	ld	ix,DATA.level_cursor_table_addr
	ld	de,VAR.level_indices_attr_addr
	ld	b,3
	jr	draw_cursor

swap_selection:
	ld	a,(DATA.is_world_selection_active)
	xor	1
	ld	(DATA.is_world_selection_active),a
	ret

move:
	ld	a,(DATA.is_world_selection_active)
	or	a
	jr	nz,.swap_to_level
	call	move_world_cursor
	jr	draw_world_cursor
.swap_to_level:
	call	move_level_cursor
	jr	draw_level_cursor

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