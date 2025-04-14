	module	RENDER

; + HL - char address
; + DE - screen address
draw_symbol:
	ld	b,8
.loop:
	ld	a,(hl)
	ld	(de),a
	inc	d
	inc	hl
	djnz	.loop
	ret

; + HL - char address
; + DE - screen address
draw_bold_symbol:
	ld	b,8
.loop:
	ld	a,(hl)
	rrca
	or	(hl)
	ld	(de),a
	inc	d
	inc	hl
	djnz	.loop
	ret
; + HL - char address
; + DE - screen address
draw_italic_half_bold_symbol
	ld	b,4
.l1:
	ld	a,(hl)
	rrca
	ld	(de),a
	inc	d
	inc	hl
	djnz	.l1
	ld	b,4
.l2:
	ld	a,(hl)
	rrca
	or	(hl)
	ld	(de),a
	inc	d
	inc	hl
	djnz	.l2
	ret
	
; + HL - char address
; + DE - screen address
draw_zebra_symbol:
	ld	b,4
.loop:
	ld	a,(hl)
	rrca
	or	(hl)
	ld	(de),a
	inc	d
	inc	hl
	ld	a,(hl)
	ld	(de),a
	inc	d
	inc	hl
	djnz	.loop
	ret


; + HL - attribute address
; + B - width
; + C - height
; + A - color
paint_rect:
	push	hl
	push	bc
	call	paint_attr_line
	dec	l
	ld	de,32
	dec	c
	call	.paint_column
	pop	bc
	dec	c
	pop	hl
	call	.paint_column
	dec	b
	dec	b
	exa	
	xor	a
	cp	b
	ret	z
	exa	
	inc	b
	inc	l
	jr	paint_attr_line

.paint_column:
	add	hl,de
	ld	(hl),a
	dec	c
	jr	nz,.paint_column
	ret

; + C - width
; + B - heihgt
; + A - raster
; + HL - screen address
fill_scr_area:
	dec	c
	rlc	b
	rlc	b
	rlc	b
.loop:
	push	af
	push	bc
	push	hl
	push	hl
	ld	(hl),a
	pop	de
	inc	e
	ld	b,0
	ldir
	pop	hl
	call	UTILS.down_hl
	pop	bc
	pop	af
	djnz	.loop
	ret

; + C - width
; + B - heihgt
; + A - color
; + HL - attributes address
fill_attr_area:
.loop:
	push	bc
	push	hl
.line:
	ld	(hl),a
	inc	l
	dec	c
	jr	nz,.line

	pop	hl
	ld	bc,#20
	add	hl,bc
	pop	bc
	djnz	.loop
	ret

; + A - color
; + B - length
; + HL - attribute address
paint_attr_line:
	ld	(hl),a
	inc	l
	djnz	paint_attr_line
	ret
; + C - color ink: 00000111
; + B - length
; + HL - attribute address
paint_ink_level_cursor:
	ld	a,(hl)
	and	%11111000
	or	c
	ld	(hl),a
	inc	l
	djnz	paint_ink_level_cursor
	ret
; + C - color paper: 00111000
; + B - length
; + HL - attribute address
; + Устанавливает PAPER сохраняя INK на атрибуте.
paint_paper_level_cursor:
	ld	a,(hl)
	and	%11000111
	or	c
	ld	(hl),a
	inc	l
	djnz	paint_paper_level_cursor
	ret
; + B - length
; + HL - attribute address
; + устанавливает paper в черный, оставляя цвет ink
clear_paper_level_cursor:
	ld	a,(hl)
	and	7
	ld	(hl),a
	inc	l
	djnz	clear_paper_level_cursor
	ret
; + A - to color
fade_in:
	ld	e,a
	ld	d,0
.l1:
	ei	
	halt
	ld	hl,$5800
	ld	bc,#0300
.loop:
	ld	(hl),d
	inc	hl
	dec	bc
	ld	a,c
	or	b
	jr	nz,.loop
	inc	d
	ld	a,e
	cp	d
	ret	c
	jr	.l1

fade_out:
	ld	a,8
	ei
	halt
	ld	hl,#5800
	ld	bc,#0300
	exa
.loop:
	ld	a,(hl)
	and	%00111000
	sub	1
	jr	nc,.l1
	xor	a
.l1:
	ld	e,a
	ld	a,(hl)
	and	%00000111
	sub	1
	jr	nc,.l2
	xor	a
.l2:
	ld	d,a
	ld	a,(hl)
	and	%11000000
	or	d
	or	e
	ld	(hl),a
	inc	hl
	dec	bc
	ld	a,c
	or	b
	jr	nz,.loop
	exa
	dec	a
	ret	z
	jr	fade_out + 2
; + HL - screen address
; + A - raster
; + C - length
fill_line:
	dec	c
	ld	b,0
	push	hl
	pop	de
	inc	e
	ld	(hl),a
	ldir
	ret


; + HL - word address
; + DE - screen address
; + IXL - font style
draw_word:
	ld	a,(hl)
	or	a
	ret	z
	call	draw_char
	inc	e
	inc	hl
	jr	draw_word
; + A - char
; + DE - screen address
draw_char:
	; TODO - сделать динамическое изменение шрифта при печати по какому то флагу.
	push	hl
	push	de
	push	bc
	call	UTILS.char_addr
	ld	bc,.end
	push	bc
	ld	a,ixl
	rrca	
	jp	c,draw_symbol
	rrca	
	jp	c,draw_bold_symbol
	rrca
	jp	c,draw_italic_half_bold_symbol
	pop	bc
	call	draw_zebra_symbol
.end:
	pop	bc
	pop	de
	pop	hl
	ret

; + DE - screen address
; + C - width
; + B - height
; + L - frame color
; + H - inner color
draw_frame:
	push	bc
	push	hl
	push	de
	push	de
	ld	a,c
	dec	a
	dec	a
	ld	(.draw_line + 1),a
	ld	a,b
	dec	a
	dec	a
	ld	(.draw_column + 1),a
	
	call	.draw_corner
	inc	e
	ld	hl,SPRITE.frame_top
	call	.draw_line
	call	.draw_corner
	call	UTILS.down_de_symbol
	ld	hl,SPRITE.frame_right
	call	.draw_column
	pop	de
	call	UTILS.down_de_symbol
	ld	hl,SPRITE.frame_left
	call	.draw_column
	call	.draw_corner
	inc	e
	ld	hl,SPRITE.frame_bottom
	call	.draw_line
	call	.draw_corner
	; attributes

	pop	de
	call	UTILS.scr_to_attr_de
	ex	de,hl
	pop	ix
	ld	a,ixl
	pop	bc
	push	bc
	push	hl
	call	fill_attr_area
	pop	hl
	ld	bc,33
	add	hl,bc
	pop	bc
	dec	c
	dec	c
	dec	b
	dec	b
	ld	a,ixh
	jp	fill_attr_area

.draw_column:
	ld	b,0
.l2:
	push	bc
	push	de
	push	hl
	ld	(.frame_sprite_addr + 1),hl
	call	.draw_part
	pop	hl
	pop	de
	call	UTILS.down_de_symbol
	pop	bc
	djnz	.l2
	ret
.draw_line:
	ld	b,0
.l1:
	push	bc
	push	de
	push	hl
	ld	(.frame_sprite_addr + 1),hl
	call	.draw_part
	pop	hl
	pop	de
	inc	e
	pop	bc
	djnz	.l1
	ret
.draw_part:
	push	de
.frame_sprite_addr:
	ld	hl,0
	call	draw_symbol
	pop	de
	ret
.draw_corner:
	ld	hl,SPRITE.frame_corner
	ld	(.frame_sprite_addr + 1),hl
	call	.draw_part
	ret

; + DRAW LEVEL with all objects !!!
draw_level:


	; подготовить 2 вида стен текущего мира.
	ld	a,(DATA.world_index)
	call	UTILS.get_sprite_wall_address
	call	UTILS.sprite_dublication_with_4_bit_offset

	; начинаем отрисовывать стены уровня.
	ld	hl,#4000
	ld	bc,MAX_LEVEL_SIZE + MAX_LEVEL_SIZE * 256
	ld	ix,DATA.walls_layer

.loop:
	xor	a
	ld	(DATA.rolling_x_bit),a
	push	bc
	push	hl
.row:
	ld	a,(ix)
	inc	ix
	or	a
	push	bc
	push	hl
	ld	a,(DATA.rolling_x_bit)
	call	nz,draw_wall
	pop	hl
	pop	bc
	inc	l
	ld	a,(DATA.rolling_x_bit)
	rrca
	jr	nc,.next_symbol
	inc	l
.next_symbol:
	ld	a,(DATA.rolling_x_bit)
	inc	a
	ld	(DATA.rolling_x_bit),a
	dec	c
	jr	nz,.row

.end_row:

	pop	hl
	;	TODO ....AAAAAAAAAAAAAAAAAA.....
	call	UTILS.down_hl_symbol
	call	UTILS.down_hl
	call	UTILS.down_hl
	call	UTILS.down_hl
	call	UTILS.down_hl
	pop	bc
	djnz	.loop
					; draw containers



	; TODO - Убрать блок - нужно использовать всего 1 раз. Если коробки будут разные то сдвиг коробок нужно тут оставить.
	;-----------------------------------------------------------------------
	; создаем по 8 сдвинутых спрайтов для коробки и для персонажа.
	ld	hl,SPRITE.character
	ld	de,DATA.player_sprite_buffer
	call	UTILS.multiply_sprite_16x16_to_24x16
	; TODO сдлеать рандомный выбор коробок из существующих вариантов.
	ld	hl,SPRITE.crate_v2
	ld	de,DATA.crate_sprite_buffer
	call	UTILS.multiply_sprite_16x16_to_24x16
	;-----------------------------------------------------------------------





	ld	ix,DATA.containers_data
	ld	a,(DATA.LEVEL.crates)
	ld	b,a
	push	bc
.draw_containers:
	push	bc
	call	.screen_address_of_object
	ld	de,SPRITE.container_left
	call	draw_object
	pop	bc
	djnz	.draw_containers
					; draw crates
	pop	bc
	ld	ix,DATA.crates_data
.draw_crates:
	push	bc
	call	.screen_address_of_object
	ld	de,DATA.crate_sprite_buffer
	call	draw_object_24x16
	pop	bc
	djnz	.draw_crates
					; draw player
	ld	ix,DATA.player_data
	call	.screen_address_of_object
	ld	de,DATA.player_sprite_buffer
	call	draw_object_24x16
	ret

; + IX - objects data
; + return: HL - screen address for draw object
; + return: IX += Object.length
; + return: A - X position
.screen_address_of_object:
	ld	e,(ix + Object.X)
	ld	d,(ix + Object.Y)
	call	UTILS.get_screen_addr
	ld	(ix + Object.SCR_ADDR),l
	ld	(ix + Object.SCR_ADDR + 1),h
	ld	a,e			; X position
	ld	de,Object
	add	ix,de
	ret

; + DE - sprite address
; + HL - screen address
; + A - position X
draw_object_24x16:
	rrca
	jr	nc,draw_sprite_24x16
	ex	de,hl
	ld	bc,3*16*4
	add	hl,bc
	ex	de,hl
; + HL - screen address
; + DE - sprite address
draw_sprite_24x16:
	ld	b,12
.loop:
	ld	a,(de)
	or	(hl)
	ld	(hl),a
	inc	l
	inc	de
	ld	a,(de)
	or	(hl)
	ld	(hl),a
	inc 	l
	inc	de
	ld	a,(de)
	or	(hl)
	ld	(hl),a
	dec 	l
	dec 	l
	inc	de
	call	UTILS.down_hl
	djnz	.loop
	ret
; + Рисует стену при построении уровня. Выбирает один из 2х вариантов стен рандомно.
; + Каждый вариант имет 2 спрайта, стандартный и сдвинутый на 4 бита.
; + За счет координаты X происходит выбор какой именно спрайт рисовать.
draw_wall:
	exa
	push	hl
	call	UTILS.Rand16
	ld	a,l
	sbc	h
	cp	#40
	ld	hl,DATA.player_sprite_buffer
	jr	c,.next_wall
	ld	bc,64
	add	hl,bc
.next_wall:
	ex	de,hl
	pop	hl
	exa

; + DE - sprite address
; + HL - screen address
; + A - position X
draw_object:
	rrca
	jr	nc,draw_sprite_16x16
	ex	de,hl
	ld	bc,32
	add	hl,bc
	ex	de,hl

; + HL - screen address
; + DE - sprite address
draw_sprite_16x16:
	ld	b,#0c
.loop:
	ld	a,(de)
	or	(hl)
	ld	(hl),a
	inc	l
	inc	de
	ld	a,(de)
	or	(hl)
	ld	(hl),a
	dec 	l
	inc	de
	call	UTILS.down_hl
	djnz	.loop
	ret

; + HL - screen address
; + DE - clean mask			
clear_sprite_24x12:
	ld	b,12
.loop:

	ld	a,(de)
	and	(hl)
	ld	(hl),a
	inc	l
	inc	de

	ld	a,(de)
	and	(hl)
	ld	(hl),a
	inc	l
	inc	de

	ld	a,(de)
	and	(hl)
	ld	(hl),a
	dec	l
	dec	l
	dec	de
	dec	de
	call	UTILS.down_hl
	djnz	.loop
	ret

clear_screen:
	ld	hl,#4000
	ld	de,#4001
	ld	bc,6143
	ld	(hl),l
	ldir
	ret
; + A - attribute color
clear_attributes:
	ld	hl,#5800
	ld	de,#5801
	ld	bc,#02FF
	ld	(hl),a
	ldir
	ret
; + сначала нужно подготовить данные вызвав: DATA.growing_text_char_data_generator
growing_text:
	xor	a
	ld	(DATA.growing_text_is_animate),a
	ld	c,7
	ld	a,(DATA.growing_bit)
	inc	a
	cp	8
	jr	nz,.l1
	ld	a,c
.l1:
	ld	(DATA.growing_bit),a
	ld	b,a
	di
	ld	ix,DATA.growing_text_scr_addresses
	ld	iy,DATA.growing_text_char_addresses
.loop:
	ld	a,(iy)
	or	a
	jr	z,.exit
	ld	h,a
	ld	a,(ix + 1)
	ld	d,a
	and	c
	cp	c
	jr	z,.cont
	ld	a,b
	or	a
	jr	z,.exit
	ld	l,(iy + 1)
	ld	e,(ix)
	call	draw_growing_char
	dec	(ix + 1)
	ld	a,b
	ld	(DATA.growing_text_is_animate),a
	dec	b
	xor	a
	cp	b
	jr	nz,.cont
	ld	b,0
.cont:
	inc	ix
	inc	ix
	inc	iy
	inc	iy
	jr	.loop

.exit:
	ld	iy,#5C3A
	ei
	ret


; + HL - char addr
; + DE - screen addr
; + C = 7
draw_growing_char:
.loop:
	push	bc
	ld	a,(hl)
	ld	c,a
	rrca
	or	c
	ld	(de),a
	pop	bc
	inc	d
	ld	a,d 
	and	c
	ret	z
	inc	l
	jr	.loop:

; + D - color
; grid:
; 	ld      hl,#5800
; 	ld      bc,#0300
; 	ld      e,%01000000
; .loop:
; 	ld      a,l
; 	and     #1F
; 	ld      a,d
; 	jr      nz,.this_line
; 	xor     e
; .this_line:
; 	xor     e
; 	ld      d,a
; 	ld      (hl),a
; 	inc     hl
; 	dec     bc
; 	ld      a,b
; 	or      c
; 	ret     z
; 	jr      .loop
	endmodule