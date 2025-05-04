	module	LEVEL_SELECTION


init:
	xor	a
	call	RENDER.clear_attributes
	call	RENDER.clear_screen


	ld	ixl,FONT_NORMAL
	call	draw_world_indices
	call	draw_level_indices

	ld	a,3
	call	RENDER.fade_in

	ld	de,#4022
	ld	bc,4 + 12 * 256
	ld	hl,2 + 3 * 256
	call	RENDER.draw_frame
	ld	de,#4029
	ld	bc,21 + 22 * 256
	ld	hl,2 + 3 * 256
	call	RENDER.draw_frame

	call	show_info
	
	ld	hl,#5800
	ld	a,6
	ld	b,#20
	call	RENDER.paint_attr_line
	call	draw_labels

	call	draw_world_index_value
	call	draw_level_index_value


	ld	hl,SWL_LEVEL_ATTR_ADDR + 33
	ld	a,5 << 3
	ld	bc,19 + 20 * 256
	call	RENDER.fill_attr_area

	call	paint_frame
	call	paint_world_field_attr
	call	paint_level_field_attr

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

; + раскрасить поле выбора мира
paint_world_field_attr:
	ld	hl,SWL_WORLD_ATTR_ADDR + 33
	ld	b,MAX_WORLDS
	ld	a,(DATA.world_index)
	ld	c,a
	ld	a,MAX_WORLDS
	sub	c
	ld	c,a
	ld	e,SWL_WORLD_FIELD_SELECTED_COLOR
	ld	a,(DATA.is_world_selection_active)
	or	a
	jr	z,.loop
	ld	e,SWL_WORLD_FIELD_UNSELECTED_COLOR
.loop:
	push	bc
	ld	a,b
	cp	c
	jr	nz,.not_selected
	ld	a,(DATA.is_world_selection_active)
	or	a
	ld	a,SWL_WORLD_FIELD_SELECTED_CURSOR_COLOR
	jr	z,.paint
	ld	a,SWL_WORLD_FIELD_UNSELECTED_CURSOR_COLOR
	jr	.paint
.not_selected:
	ld	a,e
.paint:
	ld	b,2
	call	RENDER.paint_attr_line
	dec	l
	dec	l
	ld	bc,32
	add	hl,bc
	pop	bc
	djnz	.loop
	ret
; + раскрасить поле выбора уровня
paint_level_field_attr:
	call	UTILS.get_levels_addr_by_world
	push	hl
	pop	de
	call	get_address_of_level_indices_of_each_world
	ld	c,(hl)
	ld	ix,20
	ld	hl,SWL_LEVEL_ATTR_ADDR + 33
	ld	a,(DATA.is_world_selection_active)
	or	a
	jr	nz,.field_selected
.field_unselected:
	push	hl
	ld	b,5
.nul1:
	push	bc
	ld	a,ixh
	inc	ixh
	cp	c
	ld	a,(de)
	inc	de
	jr	z,.u_cursor_selected
	or	a
	call	z,.paint_level_field_unselected
	call	nz,.paint_level_field_unselected_completed
.end2:
	inc	l
	pop	bc
	djnz	.nul1
	pop	hl
	ld	a,c
	ld	bc,32
	add	hl,bc
	ld	c,a
	dec	ixl
	jr	nz,.field_unselected
	ret
.u_cursor_selected:
	or	a
	call	z,.paint_level_field_unselected_cursor
	call	nz,.paint_level_field_unselected_cursor_completed
	jr	.end2

.field_selected:
	push	hl
	ld	b,5
.nsl1:
	push	bc
	ld	a,ixh
	inc	ixh
	cp	c
	ld	a,(de)
	inc	de
	jr	z,.cursor_selected
	or	a
	call	z,.paint_level_field_selected
	call	nz,.paint_level_field_selected_completed
.end:
	inc	l
	pop	bc
	djnz	.nsl1
	pop	hl
	ld	a,c
	ld	bc,32
	add	hl,bc
	ld	c,a
	dec	ixl
	jr	nz,.field_selected
	ret
.cursor_selected:
	or	a
	call	z,.paint_level_field_selected_cursor
	call	nz,.paint_level_field_selected_cursor_completed
	jr	.end
.paint_level_field_selected_completed:
	exa
	ld	a,SWL_LEVEL_FIELD_SELECTED_COMPLETED_COLOR
	jr	.paint_level_field
.paint_level_field_selected:
	exa
	ld	a,SWL_LEVEL_FIELD_SELECTED_COLOR
	jr	.paint_level_field
.paint_level_field_selected_cursor:
	exa
	ld	a,SWL_LEVEL_FIELD_SELECTED_CURSOR_COLOR
	jr	.paint_level_field
.paint_level_field_selected_cursor_completed:
	exa
	ld	a,SWL_LEVEL_FIELD_SELECTED_CURSOR_COMPLETED_COLOR
	jr	.paint_level_field
.paint_level_field_unselected:
	exa
	ld	a,SWL_LEVEL_FIELD_UNSELECTED_COLOR
	jr	.paint_level_field
.paint_level_field_unselected_completed:
	exa
	ld	a,SWL_LEVEL_FIELD_UNSELECTED_COMPLETED_COLOR
	jr	.paint_level_field
.paint_level_field_unselected_cursor:
	exa
	ld	a,SWL_LEVEL_FIELD_UNSELECTED_CURSOR_COLOR
	jr	.paint_level_field
.paint_level_field_unselected_cursor_completed:
	exa
	ld	a,SWL_LEVEL_FIELD_UNSELECTED_CURSOR_COMPLETED_COLOR
	; jr	.paint_level_field
.paint_level_field:
	ld	b,3
	call	RENDER.paint_attr_line
	exa
	ret

paint_frame:
	ld	a,(DATA.is_world_selection_active)
	ld	de,SWL_WORLD_FRAME_SELECTED_COLOR + SWL_LEVEL_FRAME_COLOR * 256
	or	a
	jr	z,.world_selected
	ld	de,SWL_WORLD_FRAME_COLOR + SWL_LEVEL_FRAME_SELECTED_COLOR * 256
.world_selected:
	ld	a,e
	ld	hl,SWL_WORLD_ATTR_ADDR
	ld	bc,4 + 12 * 256
	push	de
	call	RENDER.paint_attr_rect
	pop	de
	ld	a,d
	ld	hl,SWL_LEVEL_ATTR_ADDR
	ld	bc,21 + 22 * 256
	jp	RENDER.paint_attr_rect

; paint_world_frame_attributes:
; 	ld	c,%00111000
; 	ld	a,(DATA.is_world_selection_active)
; 	or	a
; 	jr	z,.l1
; 	ld	c,%00001011
; .l1:	
; 	ld	a,c
; 	ld	hl,#5843
; 	ld	bc,2 + 10 * 256
; 	call	RENDER.fill_attr_area
; 	ld	de,VAR.world_indices_attr_addr
; 	ld	a,(DATA.world_index)
; 	ld	c,%00010000
; 	ld	b,2
; 	jp	paint_paper_line

	
; paint_level_frame_attributes:
; 	ld	c,%00111000
; 	ld	a,(DATA.is_world_selection_active)
; 	or	a
; 	jr	nz,.l1
; 	ld	c,%00001011
; .l1:	
; 	ld	a,c	
; 	ld	hl,#584A
; 	ld	bc,19 + 20 * 256
; 	call	RENDER.fill_attr_area

; 	ld	a,(DATA.world_index)
; 	ld	e,MAX_LEVELS
; 	ld	d,0
; 	call	UTILS.mul_de_a
; 	ld	bc,DATA.progress
; 	add	hl,bc
; 	push	hl
; 	pop	ix

; 	ld	hl,VAR.level_indices_attr_addr
; 	ld	b,MAX_LEVELS
; .loop:
; 	push	bc
; 	ld	a,(ix)
; 	ld	e,(hl)
; 	inc	hl
; 	ld	d,(hl)
; 	inc	hl
; 	or	a
; 	jr	z,.not_paint
; 	push	hl
; 	ex	de,hl
; 	ld	c,4
; 	ld	b,3
; 	call	RENDER.paint_ink_level_cursor
; 	pop	hl
; .not_paint:
; 	inc	ix
; 	pop	bc
; 	djnz	.loop
; 	call	get_address_of_level_indices_of_each_world
; 	ld	a,(hl)
; 	ld	de,VAR.level_indices_attr_addr
; 	ld	c,%00010000
; 	ld	b,3
; 	jr	paint_paper_line


show_info:
	ld	ixl,FONT_ITALIC_HALF_BOLD
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
; paint_paper_line:
; 	push	bc
; 	rlca
; 	add 	e
; 	ld 	l,a
; 	adc 	d
; 	sub 	l
; 	ld 	h,a
; 	ld	a,(hl)
; 	inc	hl
; 	ld	h,(hl)
; 	ld	l,a

; 	pop	bc
; 	jp	RENDER.paint_paper_level_cursor

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
	call	paint_world_field_attr
	call	paint_level_field_attr
	jp	paint_frame
	; call	draw_world_index_value
	; call	draw_level_index_value
	; call	paint_world_frame_attributes
	; jp	paint_level_frame_attributes

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
	call	paint_world_field_attr
	call	paint_level_field_attr
	call	draw_level_index_value
	jp	draw_world_index_value
	; call	paint_world_frame_attributes
	; jp	paint_level_frame_attributes
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
	call	paint_level_field_attr
	jp	draw_level_index_value
	; jp	paint_level_frame_attributes
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
	ld	ixl,FONT_ITALIC_HALF_BOLD
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
	ld	ixl,FONT_BOLD
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
	ld	ixl,FONT_BOLD
	jp	RENDER.draw_word


	endmodule
