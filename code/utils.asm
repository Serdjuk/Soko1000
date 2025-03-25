	module UTILS

; + if z != 0 {pressed}
wait_any_key:
        xor a
        in a,(#fe)
        cpl
        and #1f
        ; jr z,$-6
        ret

; + DE - positions address (X,Y).
; + return: HL - screen address for draw.
; + return: A - position X
; + DE + 2 on exit.
get_screen_addr:
	ld	a,(de)
	push	af
	add 	low VAR.scr_offset_x
	ld 	l,a
	adc 	high VAR.scr_offset_x
	sub 	l
	ld 	h,a
	ld	c,(hl)			; x 
	inc	de
	ld	a,(de)
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
	inc	de
	pop	af
	ret
;	http://z80-heaven.wikidot.com/math#toc10
;Inputs:
;     	DE and A are factors
;Outputs:
;     	A is not changed
;     	B is 0
;     	C is not changed
;     	DE is not changed
;     	HL is the product
;Time:
;     	342+6x
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
; + shift sprite to left on 4 bits.
; + HL - end of sprite address - 1
sl_sprite_16x16_4_bits:
	ld	b,32
	xor	a
.loop:
	rld	
	dec	hl
	djnz	.loop
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
; + A - char
; + return: HL - char address 
char_addr: 
        ld 	l,a
	ld	h,0
        add 	hl,hl
        add 	hl,hl
        add 	hl,hl
	ld 	bc,#3D00 - 256
        add 	hl,bc       		; hl=address in font
        ret

; + E - X
; + D - Y
; + return: HL - map address
map_addr:
	ld	a,d
	rlca
	rlca
	rlca
	rlca
	add	e
	ld	e,a
	ld	d,0
	ld	hl,DATA.LEVEL.cells
	add	hl,de
	ret

; + A - position X
copy_player_sprite_to_buffer:
	ld	de,DATA.player_sprite_buffer
	ld	hl,SPRITE.player_left
	rrca
	jr	nc,.loop - 2
	ld	bc,32
	add	hl,bc
	ld	b,12
.loop:
	ld	a,(hl)
	ld	(de),a
	inc	hl
	inc	de
	ld	a,(hl)
	ld	(de),a
	inc	hl
	inc	de
	inc	de
	djnz	.loop
	ret

pack_progress_for_save:
	ld	hl,DATA.compressed_progress
	ld	de,DATA.compressed_progress + 1
	ld	bc,124
	ld	(hl),0
	ldir
	push	hl
	ld	de,DATA.progress
	pop	hl
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
	ld	de,DATA.compressed_progress
	ld	hl,DATA.progress
	ld	bc,DATA.world_index * DATA.level_index
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