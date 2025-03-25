	module	CONVERT

; + HL - packed level addr
; + crates number = 4 bits
; + x, width - 4  bits each
; + y, height - 4  bits each
; + PACKED DATA: cratesNumber, width, height, cells[][], containersXY[], cratesXY[], characterXY[]
depack:
	push	hl
	pop	ix
	ld	e,0b10000000		; маска стартового бита.
	call	next_4_bits_to_byte
	ld	(DATA.LEVEL.crates),a
	call	next_4_bits_to_byte
	ld	(DATA.LEVEL.width),a
	ld	c,a
	call	next_4_bits_to_byte
	ld	(DATA.LEVEL.height),a
	ld	b,a
	ld	hl,DATA.LEVEL.cells

	push	bc
	call	calc_level_offset
	ld	a,(DATA.LEVEL.offsetY)
	rlca
	rlca
	rlca
	rlca
	ld	c,a
	ld	a,(DATA.LEVEL.offsetX)
	add	c
	ld	c,a
	ld	b,0
	add	hl,bc
	pop	bc
.loop:
	push	bc
	push	hl
	call	depack_level_rows
	pop	hl
	ld	bc,MAX_LEVEL_SIZE
	add	hl,bc
	pop	bc
	djnz	.loop

	ld	a,(DATA.LEVEL.crates)
	rlca				; кол-во коробок * 2, так как координаты две.
	push	af
	ld	b,a
	ld	hl,DATA.LEVEL.containersXY
.set_containers_positions:
	call	next_4_bits_to_byte
	ld	(hl),a
	inc	hl
	djnz	.set_containers_positions
	pop	bc
	ld	hl,DATA.LEVEL.cratesXY
.set_crates_positions:
	call	next_4_bits_to_byte
	ld	(hl),a
	inc	hl
	djnz	.set_crates_positions
	ld	b,2
	ld	hl,DATA.LEVEL.playerXY
.set_char_position:
	call	next_4_bits_to_byte
	ld	(hl),a
	inc	hl
	djnz	.set_char_position
	ret

; + E - bit mask
; + C - bits number
; + HL - bytes address
; + IX - packed data
depack_level_rows:
	push	bc
	ld	a,(ix)			; текущий байт для побитового разбора.
.loop:
	push	af
	and	e
	ld	(hl),a			; 0 - пол; !0 - стена
	pop	af
	inc	hl
	dec	c			; счетчик битов -1
	jr	z,.exit;		; пройдены все `C` бит.
	call	inc_current_byte_addr
	jr	nc,.loop		; продолжаем операцию над текущим байтом.
	jr	.loop-3			; получаем следующий байт.
.exit:
	call	inc_current_byte_addr
	pop	bc	
	ret
inc_current_byte_addr:
	rrc	e			; свиг маски бита.
	ret	nc
	inc	ix			; сместить IX на доставку следующего байта.
	ret

; + E - bit mask
; + IX - packed data
; + return: A - byte from 4 bits
next_4_bits_to_byte:
	push	bc
	ld	c,4			; кол-во битов которые нужно считать и установить в байт.
	ld	b,0			; регистр для результата.
	ld	a,(ix)			; текущий байт для побитового разбора.
.loop:
	push	af
	and	e
	jr 	z,.res_bit
	set	7,b
.res_bit:
	rlc	b
	pop	af
	dec	c			; счетчик битов -1
	jr	z,.exit
	call	inc_current_byte_addr
	jr	nc,.loop		; продолжаем операцию над текущим байтом.
	jr	.loop-3			; получаем следующий байт.
.exit:
	call	inc_current_byte_addr
	ld	a,b
	pop	bc
	ret

; + A - world index.
; + C - level index.
; + return: HL - packed level address.
get_level_address_hl:
	ld	de,PACKED.map_size
	call	UTILS.mul_de_a

	ld	de,PACKED.world_map_01
	add	hl,de			; HL - world chunk
	rlc	c
	ld	b,0
	add	hl,bc			
	ld	a,(hl)
	inc	hl
	ld	h,(hl)
	ld	l,a			; HL - offset worlds addr
	ld	bc,PACKED.world_01
	add	hl,bc			; HL - packed level addr
	ret

; + расчитать значения смещения уровня.
calc_level_offset:
					; TODO - полученное смещение округлять в большую сторону.
	ld	a,(DATA.LEVEL.width)
	neg
	add	MAX_LEVEL_SIZE
	sra	a				
	ld	(DATA.LEVEL.offsetX),a
	ld	a,(DATA.LEVEL.height)
	neg
	add	MAX_LEVEL_SIZE
	sra	a				
	ld	(DATA.LEVEL.offsetY),a
	ret

; + сместить координаты объектов уровня.
offset_level_objects_positions:
	ld	hl,DATA.LEVEL.offsetX
	ld	e,(hl)
	inc	hl
	ld	d,(hl)
	inc	hl
	ld	b,13			; кол-во смещаемых значений: 6 коробок, 6 контейнеров и координаты игрока.
.loop:
	call	set_offset		
	djnz	.loop
	ret
; + E - смещение по X
; + D - смещение по Y
; + Сместить коориднаты на заданное значение.
set_offset:
	ld	a,e
	add	(hl)
	ld	(hl),a
	inc	hl
	ld	a,d
	add	(hl)
	ld	(hl),a
	inc	hl
	ret
	endmodule