	module	LEVEL_SELECTION


init:
	xor	a
	call	RENDER.clear_attributes
	call	RENDER.clear_screen

	
	call	draw_world_indices
	call	draw_level_indices

	call	draw_level_indices_frame
	call	draw_world_indices_frame


	ld	a,3
	call	RENDER.fade_in
	call	show_info
	
	ld	hl,#5800
	ld	a,6
	ld	b,#20
	call	RENDER.paint_attr_line
	call	draw_labels

	call	draw_world_index_value
	call	draw_level_index_value

	
	call	paint_world_frame_attributes
	call	paint_level_frame_attributes



.loop:

	call	INPUT.pressed_space
	call	z,swap_selection
	call	move_cursor

	; press enter = start game
	call	INPUT.pressed_enter
	jr	nz,.end

	call	get_address_of_level_indices_of_each_world
	ld	a,(hl)
	ld	(DATA.level_index),a

	call	RENDER.fade_out
	call	RENDER.clear_screen
	LOOP	LEVEL_INFO_SCREEN.init
.end:
	LOOP	.loop

paint_world_frame_attributes:
	ld	c,%00111011
	ld	a,(DATA.is_world_selection_active)
	or	a
	jr	z,.l1
	ld	c,%00000011
.l1:	
	ld	a,c
	ld	hl,#5843
	ld	bc,2 + 10 * 256
	call	RENDER.fill_attr_area
	ld	de,VAR.world_indices_attr_addr
	ld	a,(DATA.world_index)
	ld	c,%00001000
	ld	b,2
	jp	paint_paper_line

	
paint_level_frame_attributes:
	ld	c,%00111011
	ld	a,(DATA.is_world_selection_active)
	or	a
	jr	nz,.l1
	ld	c,%00000011
.l1:	
	ld	a,c	
	ld	hl,#584A
	ld	bc,19 + 20 * 256
	call	RENDER.fill_attr_area

	ld	a,(DATA.world_index)
	ld	e,MAX_LEVELS
	ld	d,0
	call	UTILS.mul_de_a
	ld	bc,DATA.progress
	add	hl,bc
	push	hl
	pop	ix

	ld	hl,VAR.level_indices_attr_addr
	ld	b,MAX_LEVELS
.loop:
	push	bc
	ld	a,(ix)
	ld	e,(hl)
	inc	hl
	ld	d,(hl)
	inc	hl
	or	a
	jr	z,.not_paint
	push	hl
	ex	de,hl
	ld	c,4
	ld	b,3
	call	RENDER.paint_ink_level_cursor
	pop	hl
.not_paint:
	inc	ix
	pop	bc
	djnz	.loop
	call	get_address_of_level_indices_of_each_world
	ld	a,(hl)
	ld	de,VAR.level_indices_attr_addr
	ld	c,%00001000
	ld	b,3
	jr	paint_paper_line


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
	call	RENDER.paint_attr_line
	ld	hl,#5AE1
	ld	b,5
	ld	a,%01000100
	call	RENDER.paint_attr_line
	ld	hl,#5AF2
	ld	b,5
	ld	a,%01000100
	jp	RENDER.paint_attr_line

; + DE - table address
; + A - index of world or level
; + B - attribute line length
; + C - paper color
paint_paper_line:
	push	bc
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

	pop	bc
	jp	RENDER.paint_paper_level_cursor

; + return: HL - адрес в таблице в которой лежит индекс по которому расположен курсор уровня выбранного мира. 
get_address_of_level_indices_of_each_world:
	ld	a,(DATA.world_index)
	add 	low DATA.level_indices_of_each_world
	ld 	l,a
	adc 	high DATA.level_indices_of_each_world
	sub 	l
	ld 	h,a
	ret

swap_selection:
	ld	a,(DATA.is_world_selection_active)
	xor	1
	ld	(DATA.is_world_selection_active),a
	call	draw_world_index_value
	call	draw_level_index_value
	call	paint_world_frame_attributes
	jp	paint_level_frame_attributes

move_cursor:
	ld	a,(DATA.is_world_selection_active)
	or	a
	jp	nz,change_level_index	; move level cursor
	; move world cursor
	call	INPUT.pressed_up
	jr	z,.up
	call	INPUT.pressed_down
	jr	z,.down
	ret
.down:
	ld	a,(DATA.world_index)
	inc	a
	cp	MAX_WORLDS
	jr	c,.set_new_index
	xor	a
.set_new_index:
	ld	(DATA.world_index),a
	call	draw_world_index_value
	call	draw_level_index_value
	call	paint_world_frame_attributes
	jp	paint_level_frame_attributes
.up:
	ld	a,(DATA.world_index)
	sub	1
	jr	nc,.set_new_index
	ld	a,MAX_WORLDS - 1
	jr	.set_new_index


change_level_index:
	call	INPUT.pressed_left
	jr	z,.left
	call	INPUT.pressed_right
	jr	z,.right
	call	INPUT.pressed_up
	jr	z,.up
	call	INPUT.pressed_down
	jr	z,.down
	ret
.up:
	call	get_address_of_level_indices_of_each_world
	ld	a,(hl)
	sub	5
	jr	nc,.set_new_index
	sub	156
	jr	.set_new_index
.down:
	call	get_address_of_level_indices_of_each_world
	ld	a,(hl)
	add	5
	cp	MAX_LEVELS
	jr	c,.set_new_index
	add	156
	jr	.set_new_index

	
.right:
	call	get_address_of_level_indices_of_each_world
	ld	a,(hl)
	inc	a
	cp	MAX_LEVELS
	jr	c,.set_new_index
	xor	a
.set_new_index:
	ld	(hl),a
	call	draw_level_index_value
	jp	paint_level_frame_attributes
.left:
	call	get_address_of_level_indices_of_each_world
	ld	a,(hl)
	sub	1
	jr	nc,.set_new_index
	ld	a,MAX_LEVELS - 1
	jr	.set_new_index

draw_world_indices:
	ld	de,#4043
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
	call	UTILS.down_de_symbol
	pop	bc
	djnz	.loop
	ret

draw_level_indices:

	ld	de,#404A
	ld	hl,1
	ld	b,20
.loop:
	push	bc
	push	de
	ld	b,5
	call	.row
	pop	de
	call	UTILS.down_de_symbol
	pop	bc
	djnz	.loop
	ret
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
	ld	de,#4000
	call	RENDER.draw_word

	ld	hl,TEXT.text_level_label
	ld	de,#4015
	call	RENDER.draw_word
	ret

draw_world_index_value:
	ld	de,DATA.digital_value_buffer
	ld	a,(DATA.world_index)
	inc	a
	ld	l,a
	ld	h,0
	call	UTILS.num2dec.tenths
	dec	de
	dec	de
	ld	hl,#4006
	ex	de,hl
	jp	RENDER.draw_word

draw_level_index_value:
	call	get_address_of_level_indices_of_each_world
	ld	a,(hl)
	ld	de,DATA.digital_value_buffer
	push	de
	inc	a
	ld	l,a
	ld	h,0
	call	UTILS.num2dec.hundredths
	pop	de
	ld	hl,#4015 + 6
	ex	de,hl
	jp	RENDER.draw_word

draw_world_indices_frame:

	ld	hl,SPRITE.frame_corner
	ld	de,#4022
	push	de
	push	hl
	push	hl
	push	hl
	call	RENDER.draw_symbol
	pop	hl
	ld	de,#4025
	call	RENDER.draw_symbol
	pop	hl
	ld	de,#4882
	call	RENDER.draw_symbol
	pop	hl
	ld	de,#4885
	call	RENDER.draw_symbol

	pop	de
	inc	de
	ld	hl,SPRITE.frame_top
	ld	b,2
	call	draw_char_line
	ld	hl,SPRITE.frame_bottom
	ld	de,#4883
	ld	b,2
	call	draw_char_line

	ld	hl,SPRITE.frame_left
	ld	de,#4042
	ld	b,10
	call	draw_char_column
	ld	hl,SPRITE.frame_right
	ld	de,#4045
	ld	b,10
	jr	draw_char_column

draw_level_indices_frame:
	ld	de,#4029
	ld	hl, SPRITE.frame_corner
	push	de
	push	hl
	push	hl
	push	hl
	call	RENDER.draw_symbol
	pop	hl
	ld	de,#403D
	call	RENDER.draw_symbol
	pop	hl
	ld	de,#50C9
	call	RENDER.draw_symbol
	pop	hl
	ld	de,#50DD
	call	RENDER.draw_symbol
	pop	de
	inc	de
	; top + bottom
	ld	hl,SPRITE.frame_top
	ld	b,19
	call	draw_char_line
	ld	hl,SPRITE.frame_bottom
	ld	de,#50CA
	ld	b,19
	call	draw_char_line
	; left + right
	ld	hl,SPRITE.frame_left
	ld	de,#4049
	ld	b,20
	call	draw_char_column
	ld	hl,SPRITE.frame_right
	ld	de,#405D
	ld	b,20
; + B - length
; + HL - char address
; + DE - start screen address
draw_char_column:
	push	bc
	push	de
	push	hl
	call	RENDER.draw_symbol
	pop	hl
	pop	de
	call	UTILS.down_de_symbol
	pop	bc
	djnz	draw_char_column
	ret
; + B - length
; + HL - char address
; + DE - start screen address
draw_char_line:
	push	bc
	push	de
	push	hl
	call	RENDER.draw_symbol
	pop	hl
	pop	de
	inc	e
	pop	bc
	djnz	draw_char_line
	ret

	endmodule
