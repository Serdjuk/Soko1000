	module	MAIN_MENU

show_progress_info_timer:
	db	150

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

	ld	ixl,FONT_ZEBRA
	ld	hl,UTILS.char_addr.font_addr + 1
	inc	(hl)
	push	hl
	ld	hl,TEXT.text_level_authors
	ld	de,#50B2
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


	ld	a,(DATA.start_of_level_data + VAR.mm_moves - VAR.mm_moving_strings_frames)
	dec	a
	call	m,redraw

	call	menu_flyout
	ld	a,(DATA.growing_text_is_animate)
	or	a
	push	af
	call	nz,RENDER.growing_text
	pop	af
	call	z,change_level_author_name


	ld	a,(DATA.start_of_level_data + VAR.mm_moves - VAR.mm_moving_strings_frames)
	dec	a
	call	m,input


	ld	a,(#5800)
	or	a
	jr	z,.end
	ld	a,(show_progress_info_timer)
	dec	a
	jr	nz,.l1
	call	show_progress_info
	ld	a,150	
.l1:
	ld	(show_progress_info_timer),a

.end:

	LOOP	.loop

input:
	call	INPUT.pressed_up
	jr	z,.to_up
	call	INPUT.pressed_down
	jr	z,.to_down
	ld	c,ENTER
	call	INPUT.pressed_key
	jr	z,.select

	call	INPUT.fire
	jr	z,.select

	ld	c,SPACE
	call	INPUT.pressed_key
	ret	nz
.select:
	call	sound_move
	ld	a,(DATA.main_menu_selected_index)
	or	a
	jr	nz,.next_key
.start_game:
	pop	af
	LOOP 	LEVEL_SELECTION.init
.next_key:
	cp	1
	jp	z,keyboard
	cp	2
	jp	z,load_progress
	cp	3
	jp	z,save_progress
	ret
.to_down:
	ld	a,(DATA.main_menu_selected_index)
	inc	a
	cp	MAIN_MENU_ITEMS_COUNT
	jr	c,.next_id
	xor	a
.next_id:
	ld	(DATA.main_menu_selected_index),a
	call	repaint
	call	sound_cursor_move
	ret

.to_up:
	ld	a,(DATA.main_menu_selected_index)
	sub	1
	jr	nc,.prev_id
	ld	a,MAIN_MENU_ITEMS_COUNT - 1
.prev_id:
	ld	(DATA.main_menu_selected_index),a
	call	repaint
	call	sound_cursor_move
	ret

repaint:
	ld	ix,VAR.selected_attr_addr
	ld	c,0
.loop:	
	ld	a,(DATA.main_menu_selected_index)
	ld	l,(ix)
	ld	h,(ix + 1)
	cp	c
	call	paint
	inc	ix
	inc	ix
	inc	c
	ld	a,c
	cp	MAIN_MENU_ITEMS_COUNT
	ret	z
	jr	.loop

; + flag z - 
; + HL - screen address
paint:
	ld	de,VAR.menu_attr_line
	jr	nz,.no_selected
	ld	de,VAR.menu_attr_line_selected
.no_selected:
	
	ld	b,VAR.menu_attr_line.end - VAR.menu_attr_line
.next_attr:
	ld	a,(de)
	ld	(hl),a
	inc	de
	inc	l
	djnz	.next_attr
	ret


redraw:

	ld	hl,VAR.main_menu_items_addr
	ld	de,VAR.selected_attr_addr
	ld	c,0
.loop:
	push	bc
	ld	a,(de)
	inc	de
	push	de
	ld	b,a
	ld	a,(de)
	ld	d,a
	ld	e,b
	inc	e
	inc	e
	call	UTILS.attr_to_scr_de
	ld	a,(hl)
	inc	hl
	push	hl
	ld	h,(hl)
	ld	l,a
	ld	ixl, FONT_NORMAL
	ld	a,(DATA.main_menu_selected_index)
	cp	c
	jr	nz,.normal_font
	ld	ixl, FONT_BOLD
.normal_font:
	call	shaking_message
	pop	hl
	inc	hl
	pop	de
	inc	de
	pop	bc
	inc	c
	ld	a,c
	cp	MAIN_MENU_ITEMS_COUNT
	ret	z
	jr	.loop
control_bit:
	db	1

keyboard:
	; rotate bit
	ld	a,(control_bit)
	rlca
	and	7
	jr	nz,.not_zero
	inc	a
.not_zero:
	ld	(control_bit),a
	; check bit
	rrca
	jr	c,.qaop
	rrca
	jr	c,.wasd
	rrca
	ret	nc
.kempston:
	ld	hl,VAR.interfaceII
	call	.rebind
	ld	hl,TEXT.text_joystick
	ld	de,TEXT.text_keyboard
	ld	bc,13
	ldir
	ret
.qaop:
	xor	a
	ld	hl,VAR.qaop_keys
	call	.rebind
	ld	hl,TEXT.text_keyboard_clone
	ld	de,TEXT.text_keyboard
	ld	bc,13
	ldir
	ret
.wasd:
	call	.qaop
	ld	hl,VAR.wasd_keys
	call	.rebind
	ld	hl,VAR.wasd_keys
	ld	de,TEXT.text_keyboard + 9
	ld	c,4
	ldir
	ret
.rebind:
	ld	(DATA.kempston_enable),a
	ld	de,VAR.key_binding
	ld	bc,4
	ldir
	ret

save_progress:
	call	UTILS.pack_progress_for_save
	SAVE_TAPE DATA.stored_data, DATA.stored_data_end - DATA.stored_data
	ld	a,0
	out	(#FE),a
	ld	hl,TEXT.text_successfully_saved
	jr	load_progress.print

load_progress:
	LOAD_TAPE DATA.stored_data, DATA.stored_data_end - DATA.stored_data
	call	UTILS.unpack_loaded_progress
	ld	a,0
	out	(#FE),a
	ld	hl,TEXT.text_successfully_loaded
.print:
	push	hl
	call	check_correctness_data
	pop	hl
	ld	de,#4002
	ld	a,4
	jr	c,.correct
	ld	hl,TEXT.text_load_error
	ld	de,#4000
	ld	a,2
.correct:
	ld	ixl,FONT_ITALIC_HALF_BOLD
	push	af
	call	RENDER.draw_word
	pop	af
; + A - color
show_progress_info:

	ld	bc,#21 + #01 * #FF
	ld	hl,#5800
	jp	RENDER.fill_attr_area

; + return: error if flag C is reset
check_correctness_data:
	ld	hl,DATA.stored_data
	ld	b,MAX_WORLDS
.check_indices:
	ld	a,(hl)
	inc	hl
	cp	MAX_LEVELS
	ret	nc
	djnz	.check_indices
	ld	a,(hl)			; level color, без проверки на 0. не может быть цвета == 0
	cp	8
	ret	nc
	inc	hl
	ld	a,(hl)			; smooth motion
	cp	3
	ret	nc
	inc	hl
	ld	a,(hl)			; world index
	cp	MAX_WORLDS
	ret	nc
	inc	hl
	ld	a,(hl)			; level index
	cp	MAX_LEVELS
	ret

menu_frame:

	ld	bc,32 + 11*256
	ld	hl,#5800
	ld	a,%01000111
	call	RENDER.fill_attr_area

	ld	hl,#4745
	ld	c,18
	ld	a,%01010101
	call	RENDER.fill_line
	ld	hl,#4086
	ld	c,18
	ld	a,%01010101
	call	RENDER.fill_line

	ld	hl,#4787
	ld	c,18
	ld	a,%01010101
	call	RENDER.fill_line
	ld	hl,#40C8
	ld	c,18
	ld	a,%01010101
	call	RENDER.fill_line

	ld	hl,#47C9
	ld	c,18
	ld	a,%01010101
	call	RENDER.fill_line
	ld	hl,#480A
	ld	c,18
	ld	a,%01010101
	call	RENDER.fill_line

	ld	hl,#4F0B
	ld	c,18
	ld	a,%01010101
	call	RENDER.fill_line
	ld	hl,#484C
	ld	c,18
	ld	a,%01010101
	call	RENDER.fill_line

	call	repaint
	ret

menu_flyout:
	ld	a,(DATA.start_of_level_data + VAR.mm_moves - VAR.mm_moving_strings_frames)
	dec	a
	ret	m
	ld	(DATA.start_of_level_data + VAR.mm_moves - VAR.mm_moving_strings_frames),a

	ld	hl,DATA.start_of_level_data
	ld	ix,DATA.start_of_level_data + (VAR.mm_moving_strings_scr_addrs - VAR.mm_moving_strings_frames)
	ld	b,4
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

	ld	b,4
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
	
	ld	a,(DATA.start_of_level_data + VAR.mm_moves - VAR.mm_moving_strings_frames)
	dec	a
	cp	#FF
	jp	z,menu_frame
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
	ld	(hl),%00000001
	inc	l
	ld	(hl),%00001101
	dec	(ix)
	ret
.secondary_attr:
	ld	(hl),%00001000
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
; + flag z - печать дрожащего текста или обычного.
; + HL - message address
; + DE - screen address
shaking_message:
	jp	z,RENDER.draw_word
.loop:
	ld	a,(hl)
	or	a
	ret	z
	push	bc
	push	hl
	push	de
	call	UTILS.char_addr
	call	shaking_char
	pop	de
	inc	e
	pop	hl
	inc	hl
	pop	bc
	jr	.loop
	
; + HL - char address
; + DE - screen address
shaking_char:
	push	hl
.shift_addr:
	ld	hl,0
	ld	a,(hl)
	ld	ixh,a
	inc	hl
	ld	a,(hl)
	inc	hl
	bit	5,h
	jr	z,.l1
	ld	h,0
.l1:
	ld	(.shift_addr + 1),hl
	pop	hl
	and	2
	rrca
	add	l
	ld	l,a
	ld	bc,.draw
	push	bc
	ld	a,ixl
	rrca	
	jp	c,RENDER.draw_symbol
	rrca	
	jp	c,RENDER.draw_bold_symbol
	rrca
	jp	c,RENDER.draw_italic_half_bold_symbol
	pop	bc
	call	RENDER.draw_zebra_symbol
.draw:
	ex	de,hl
	ld	b,8
	ld	a,ixh
	and	2
	ret	z
	rrca
	jr	c,.shift_to_right
.shift_to_left:
	dec	h
	; rlc	(hL)
	db	#CB,#06
	djnz	.shift_to_left
	ret
.shift_to_right:
	dec	h
	; rrc	(hL)
	db	#CB,#0E
	djnz	.shift_to_right
	ret
	





	endmodule