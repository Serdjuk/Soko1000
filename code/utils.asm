	module UTILS
; + A - frames
pause:
	ei
	halt
	dec	a
	ret	z
	jr	pause

; + if z != 0 {pressed}
wait_any_key:
        xor a
        in a,(#fe)
        cpl
        and #1f
        ; jr z,$-6
        ret

; + E - X
; + D - Y
; + return: HL - screen address.
get_screen_addr:
	ld	a,e
	add 	low VAR.scr_offset_x
	ld 	l,a
	adc 	high VAR.scr_offset_x
	sub 	l
	ld 	h,a
	ld	c,(hl)			; x 
	ld	a,d
	rlca
	add 	low VAR.scr_addr_y
	ld 	l,a
	adc 	high VAR.scr_addr_y
	sub 	l
	ld 	h,a
	ld	a,(hl)
	inc	hl
	ld	h,(hl)
	ld	l,a
	ld	b,0
	add	hl,bc	
	ret


; + A - (Object.SHIFT_BIT)
; + BC - sprite buffer
; + return: HL - offset of sprite buffer
offset_of_sprite_buffer_hl:
	push	bc
	ld	l,a
	ld	h,0
	add	hl,hl
	add	hl,hl
	add	hl,hl
	add	hl,hl
	ld	b,h
	ld	c,l
	add	hl,hl
	add	hl,bc
	pop	bc
	add	hl,bc
	ret

; + 	http://z80-heaven.wikidot.com/math#toc10
; + Inputs:
; +      	DE and A are factors
; + Outputs:
; +      	A is not changed
; +      	B is 0
; +      	C is not changed
; +      	DE is not changed
; +      	HL is the product
; + Time:
; +      	342+6x
mul_de_a:
	ld 	b,8          	;7           7
	ld	hl,0         	;10         10
	add	hl,hl		;11*8       88
	rlca          		;4*8        32
	jr	nc,$+3     	;(12|18)*8  96+6x
	add	hl,de   	;--         --
	djnz	$-5      	;13*7+8     99
	ret             	;10         10

down_de:
	inc d
        ld  a,d
        and 7
        ret nz
        ld  a,e
        add a,32
        ld  e,a
        ret c
        ld  a,d
        sub 8
        ld  d,a
        ret  
down_hl:
	inc h
        ld  a,h
        and 7
        ret nz
        ld  a,l
        add a,32
        ld  l,a
        ret c
        ld  a,h
        sub 8
        ld  h,a
        ret 
; + @bfox_zx
up_hl:
	ld  	a,h
	dec 	h
	and 	7
	jr 	nz,$+11
	ld  	a,l
	add 	a,#e0
	ld  	l,a
	sbc 	a,a
	and 	#08
	add 	a,h
	ld  	h,a
	ret

; DE > screen address
; current symbol address + 8 lines (vertical)
down_de_symbol:
	ld a,e
	add #20
	ld e,a
	ret nc
	ld a,d
	add 8
	ld d,a
	ret	
down_hl_symbol:
	ld a,l
	add #20
	ld l,a
	ret nc
	ld a,h
	add 8
	ld h,a
	ret	
; + down hl screen address by 12 lines
down_hl_12:
	ld 	a,l
	add 	#20
	ld 	l,a
	ret 	nc
	ld 	a,h
	add	12
	ld	h,a

	ret
; + A - world index
; + Получаем адрес спрайта шаблона стены который будет использоваться в текущем мире.
get_sprite_wall_address:
	ld	l,a
	ld	h,0
	add	hl,hl
	add	hl,hl
	add	hl,hl
	add	hl,hl
	add	hl,hl
	add	hl,hl
	ld	bc,SPRITE.wall_01_v1
	add	hl,bc
	ret

; + HL - template sprite address
; + Копируется шаблон спрайта и создается еще одна его копия сдвинутая на 4 бита по адресу:  DATA.player_sprite_buffer (для двух шаблонов подряд)
sprite_dublication_with_4_bit_offset:
	ld	b,2
	ld	de,DATA.player_sprite_buffer
.loop:
	push	bc
	push	hl
	push	de
	ld	bc,32
	push	bc
	ldir
	pop	bc
	pop	hl
	ldir
	call	sr_sprite_16x16_4_bits
	pop	hl
	ld	bc,32
	add	hl,bc
	pop	bc
	djnz	.loop
	ret
; + shift sprite to right on 4 bits.
; + HL - sprite address
sr_sprite_16x16_4_bits:
	ld	b,32
	xor	a
.loop:
	rrd	
	inc	hl
	djnz	.loop
	ret

; + Convert screen address to attribute address
; + DE = screen address
; + return DE = attributes address
scr_to_attr_de:
	ld 	a,d
	and 	#58
	rrca
	rrca
	rrca
	or 	#58
	ld 	d,a
	ret

; + Convert screen address to attribute address
; + HL = screen address
; + return HL = attributes address
scr_to_attr_hl:
	ld 	a,h
	and 	#58
	rrca
	rrca
	rrca
	or 	#58
	ld 	h,a
	ret

	; ld a,d
        ; rrca
        ; rrca
        ; rrca
        ; and 3
        ; add #58
        ; ld d,a

; + #58	01011000	#40	01000000
; + #59	01011001	#48	01001000
; + #5A	01011010	#50	01010000
; + DE - attribute address
; + return DE = screen address
attr_to_scr_de:
	ld	a,d
	and	#03
	rlca
	rlca
	rlca
	or	#40
	ld	d,a
	ret

; + Input: HL = number to convert, DE = location of ASCII string
; + Output: ASCII string at (DE)
; + https://map.grauw.nl/sources/external/z80bits.html#5.1
num2dec:
	ld	bc,-10000
	call	.num1
.thousandths:
	ld	bc,-1000
	call	.num1
.hundredths:
	ld	bc,-100
	call	.num1
.tenths:
	ld	bc,-10
	call	.num1
.dig:					; set B #FF if need one digit
	ld	c,b

.num1	ld	a,'0'-1
.num2	inc	a
	add	hl,bc
	jr	c,.num2
	sbc	hl,bc
	ld	(de),a
	inc	de
	xor	a
	ld	(de),a
	ret

; + HL = pseudo-random number, period 65536
Rand16	ld	de,12345		; Seed is usually 0
	ld	a,d
	ld	h,e
	ld	l,253
	or	a
	sbc	hl,de
	sbc	a,0
	sbc	hl,de
	ld	d,0
	sbc	a,d
	ld	e,a
	sbc	hl,de
	jr	nc,Rand
	inc	hl
Rand	ld	(Rand16+1),hl
	ret

; + A - char
; + return: HL - char address 
char_addr: 
        ld 	l,a
	ld	h,0
        add 	hl,hl
        add 	hl,hl
        add 	hl,hl
.font_addr:
	ld 	bc,#3D00 - 256
        add 	hl,bc       		; hl=address in font
        ret
; + A - object index
; + IX - objects map address
; + return: IX - object address by index
; + 	`dec a` вначале процедуры потому что индекса 0 не бывает на слоях. Соответственно процедуру нельзя вызывать с индексом объекта равным нулю.
obj_addr:
	dec	a
	rlca
	rlca
	rlca
	add	ixl
	ld	ixl,a
	ret

; + E - X
; + D - Y
; + HL - cell address
; + return: HL - cell address on layer
cell_addr:
	push	de
	ld	a,d
	rlca
	rlca
	rlca
	rlca
	add	e
	ld	e,a
	ld	d,0
	; ld	hl,DATA.walls_layer
	add	hl,de
	pop	de
	ret

; + HL - sprite single address
; + DE - sprite buffer
; + Сдвигает спрайт 8 раз.
multiply_sprite_16x16_to_24x16:
	ld	b,16
	push	de
.copy_sprite:
	ld	a,(hl)
	ld	(de),a
	inc	de
	inc	hl
	ld	a,(hl)
	ld	(de),a
	inc	hl
	inc	de
	xor	a
	ld	(de),a
	inc	de
	djnz	.copy_sprite
	pop	hl
	ld	b,7
.loop:
	push	bc
	ld	bc,3*16
	ldir
	push	hl
	ld	b,3*16
	xor	a
.shift_right:
	rr	(hl)
	inc	hl
	djnz	.shift_right
	ex	de,hl
	pop	hl
	pop	bc
	djnz	.loop
	ret

; + HL - text address
; + DE - screen address
; + return: HL - next text address
growing_text_char_data_generator:
	ld	ix,DATA.growing_text_char_addresses
.loop:
	ld	a,(hl)
	or	a
	jr	nz,.continue
	inc	hl
	ld	(ix),0
	ex	de,hl
	call	UTILS.down_hl_symbol
	call	UTILS.up_hl
	call	UTILS.up_hl
	ex	de,hl
	ld	ix,DATA.growing_text_scr_addresses
	ld	b,AUTHORS.MAX_LENGTH
.l2:
	ld	(ix),e
	ld	(ix + 1),d
	inc	e
	inc	ix
	inc	ix
	djnz	.l2
	ld	a,b
	ld	(DATA.growing_bit),a
	inc	a
	ld	(DATA.growing_text_is_animate),a
	ret
.continue:
	push	hl
	call	char_addr
	ld	(ix),h
	ld	(ix + 1),l
	inc	ix
	inc	ix
	pop	hl
	inc	hl
	jr	.loop

; + return: HL - адрес начала сотни уровней выбранного мира.
get_levels_addr_by_world:
	ld	a,(DATA.world_index)
	ld	e,MAX_LEVELS
	ld	d,0
	call	UTILS.mul_de_a
	ld	bc,DATA.progress
	add	hl,bc
	ret

	
; + меняет прогресс прохождения.
; + устанавливает флаг о том что уровень был пройден.
set_progress:
	ld	a,(DATA.world_index)
	ld	e,100
	ld	d,0
	call	UTILS.mul_de_a
	ld	a,(DATA.level_index)
	ld	e,a
	add	hl,de
	ld	de,DATA.progress
	add	hl,de
	inc	(hl)
	ret


pack_progress_for_save:
	ld	hl,DATA.compressed_progress
	ld	de,DATA.compressed_progress + 1
	ld	bc,124
	ld	(hl),0
	push	hl
	ldir
	pop	hl
	ld	de,DATA.progress
	ld	b,125			; кол-во байт в 1000 битах.
.loop:
	push	bc
	ld	bc,#0880
.byte:
	ld	a,(de)
	or	a
	jr	z,.no_bit
	ld	a,c
	or	(hl)
	ld	(hl),a
.no_bit:
	inc	de
	rrc	c
	djnz	.byte
	inc	hl
	pop	bc
	djnz	.loop
	ret
	
unpack_loaded_progress:
	ld	hl,DATA.progress
	ld	de,DATA.compressed_progress
	ld	bc,125
.loop:
	push	bc
	ld	bc,#0880
.byte:
	ld	a,(de)
	and	c
	ld	(hl),a
	inc	hl
	rrc	c
	djnz	.byte
	inc	de
	pop	bc
	dec	bc
	ld	a,b
	or	c
	ret	z
	jr	.loop

	endmodule