	module	RENDER

fill_symbol:
	push	de
	push	bc
	ld	b,8
	; ld	a,#FF
.loop:
	ld	(de),a
	inc	d
	djnz	.loop
	pop	bc
	pop	de
	ret
; + A - color
; + B - length
; + HL - attribute address
draw_attr_line:
	ld	(hl),a
	inc	l
	djnz	draw_attr_line
	ret
; + C - color ink: ?????!!!
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
; + C - color paper: ??!!!???
; + B - length
; + HL - attribute address
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
	push	hl
	push	de
	push	bc
	call	UTILS.char_addr
	ld	b,8
.loop:
	ld	a,(hl)
	ld	(de),a
	inc	d
	inc	l
	djnz	.loop
	pop	bc
	pop	de
	pop	hl
	ret

; + DRAW LEVEL with all objects !!!
draw_level:
	ld	hl,#4000
	ld	bc,LEVEL.MAX_LEVEL_SIZE + LEVEL.MAX_LEVEL_SIZE * 256
	

	ld	ix,DATA.LEVEL.cells

.loop:
	; ld	a,(DATA.LEVEL.offsetX)
	; dec	a
	xor	a
	ld	(DATA.rolling_x_bit),a
	push	bc
	push	hl
.row:
	ld	a,(ix)
	inc	ix
	or	a
	ld	de,SPRITE.wall_01_left
	push	bc
	push	hl
	ld	a,(DATA.rolling_x_bit)
	call	nz,draw_object
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
					; draw objects
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

	ld	a,(DATA.LEVEL.crates)
	ld	b,a
	ld	de,DATA.LEVEL.cratesXY
.draw_crates:
	push	bc	
	call	UTILS.get_screen_addr
	push	de
	ld	de,SPRITE.crate_left
	call	draw_object
	pop	de
	pop	bc
	djnz	.draw_crates
	;				draw player
.draw_player:
	ld	de,DATA.LEVEL.playerXY
	call	UTILS.get_screen_addr
	ld	de,SPRITE.player_left
	call	draw_object
	ret

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
	ld	bc,#0c02
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