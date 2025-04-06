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

; + HL - word address
; + DE - screen address
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
	call	draw_symbol
	pop	bc
	pop	de
	pop	hl
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
	ld	ix,DATA.LEVEL.cells

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

	ld	a,(DATA.LEVEL.crates)
	ld	b,a
	ld	de,DATA.LEVEL.containersXY
.draw_containers:
	push	bc	
	call	UTILS.get_screen_addr
	push	de
	ld	de,SPRITE.container_left
	call	draw_object
	pop	de
	pop	bc
	djnz	.draw_containers


	; создаем по 8 сдвинутых спрайтов для коробки и для персонажа.
	ld	hl,SPRITE.character
	ld	de,DATA.player_sprite_buffer
	call	UTILS.multiply_sprite_16x16_to_24x16
	; TODO сдлеать рандомный выбор коробок из существующих вариантов.
	ld	hl,SPRITE.crate_v2
	ld	de,DATA.crate_sprite_buffer
	call	UTILS.multiply_sprite_16x16_to_24x16

					; draw crate
	ld	a,(DATA.LEVEL.crates)
	ld	b,a
	ld	de,DATA.LEVEL.cratesXY
.draw_crates:
	push	bc	
	call	UTILS.get_screen_addr
	push	de
	ld	de,DATA.crate_sprite_buffer
	call	draw_object_24x16
	pop	de
	pop	bc
	djnz	.draw_crates
	;				draw player
.draw_player:
	ld	de,DATA.LEVEL.playerXY
	call	UTILS.get_screen_addr
	ld	de,DATA.player_sprite_buffer
	call	draw_object_24x16
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
; + DE - clean mask			; 0b1111000000000000 || 0b0000000000001111
clear_sprite_12x12:
	ld	bc,#0c02
.loop:
	ld	a,(hl)
	and	e
	ld	(hl),a
	inc	l
	ld	a,(hl)
	and	d
	ld	(hl),a
	dec 	l
	call	UTILS.down_hl
	djnz	.loop
	ret

clear_screen:
	ld	hl,#4000
	ld	de,#4001
	ld	bc,6192
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
; + D - color
grid:
	ld      hl,#5800
	ld      bc,#0300
	ld      e,%01000000
.loop:
	ld      a,l
	and     #1F
	ld      a,d
	jr      nz,.this_line
	xor     e
.this_line:
	xor     e
	ld      d,a
	ld      (hl),a
	inc     hl
	dec     bc
	ld      a,b
	or      c
	ret     z
	jr      .loop
	endmodule