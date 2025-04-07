	module	ANIMATIONS


; сдвиг спрайтов на 12 пикселей.
; Имеется таблица смещений Х на строке в экранной области: 0,1,3,4,6,7,9,10,12,13,15,16,18,19,21,22 (от левой стороны экрана)
; По ней мы вычисляем текущее смещение в строке на экране, допустим Х = 5, из таблицы получим 7.
; Если Х четное то отрисовывается спрайт без смещения, иначе отрисовывается спрайт со смещением на 4 пикселя вправо.
; Если имееются зараннее сдвинутые спрайты 8 штук 24х16:
; 	Индексы спрайтов при смещении вправо на 12 пикселей с четной позиции: 		1,2,3,4,5,6,7 | 0,1,2,3,4
; 	Индексы спрайтов при смещении вправо на 12 пикселей с не четной позиции: 	5,6,7 | 0,1,2,3,4,5,6,7 | 0
; 	Если индекс спрайта == 0, перемещаем спрайт на следующий символ.
; 	При смещении влево перемещение на следующий символ так же если индекс спрайта == 0, но индексы в обратном порядке.
; 
; 

init:
	; создаем по 8 сдвинутых спрайтов для коробки и для персонажа.
	ld	hl,SPRITE.character
	ld	de,DATA.player_sprite_buffer
	call	UTILS.multiply_sprite_16x16_to_24x16
	ld	hl,SPRITE.crate_v2
	ld	de,DATA.crate_sprite_buffer
	call	UTILS.multiply_sprite_16x16_to_24x16

	ld	a,6
	call	RENDER.clear_attributes

	ld	a,4
	ld	(sprite_shift_bit_odd_x),a

update:
	ld	hl,(clear_addr)
	call	clear
	ld	hl,(crate_clear_addr)
	call	clear

	ld	a,(sprite_shift_bit_even_x)
	inc	a
	ld	(sprite_shift_bit_even_x),a

	ld	a,(sprite_shift_bit_odd_x)
	inc	a
	ld	(sprite_shift_bit_odd_x),a



	ld	bc,DATA.player_sprite_buffer
	ld	de,(screen_addr)
	ld	ix,clear_addr
	ld	a,(sprite_shift_bit_even_x)
	call	draw_sprite_right_12_px
	ld	(screen_addr),hl


	ld	bc,DATA.crate_sprite_buffer
	ld	de,(crate_screen_addr)
	ld	ix,crate_clear_addr
	ld	a,(sprite_shift_bit_odd_x)
	call	draw_sprite_right_12_px
	ld	(crate_screen_addr),hl


	LOOP	update
; + Хранит значение индекса спрайта для движения с четной координаты.
sprite_shift_bit_even_x:
	db	0
; + Хранит значение индекса спрайта для движения с не четной координаты.
; + Это значение всегда должно быть на 4 больше или меньше от значения sprite_shift_bit_even_x. 
sprite_shift_bit_odd_x:
	db	0

screen_addr:
	dw	#4000
clear_addr:
	dw	0

crate_screen_addr:
	dw	#4041
crate_clear_addr:
	dw	0



; + A - sprite shift bit (even/odd)
; + BC - sprite buffer start address
; + DE - screen address
; + IX - ячейка памяти в который лежит экранный адрес отчистки спрайта.
; + return:
; + 	HL - screen address
; + Возвращаемы значениея нужно сохранитьпосле вызова процедуры.
; + HL - будет смещен на 1 каждые 8 сдвигов.
draw_sprite_right_12_px:
	and	7
	push	af
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
	ex	de,hl
	; DE - sprite address
	; HL - screen address
	ld	(ix),l
	ld	(ix + 1),h
	pop	af
	jr	nz,.not_change_hl
	inc	l
.not_change_hl:
	push	hl
	call	RENDER.draw_sprite_24x16
	pop	hl
	ret


; + Хранит 3 адреса спрайтов которые должны быть отрисованы.
sprite_addr_for_draw:
	dw	0
	dw	0
	dw	0
; + Хранит 3 адреса экранной области куда должны отрисоваться спрайты.
screen_addr_for_draw_sprite:
	dw	0
	dw	0
	dw	0


; + Хранит 2 адреса экранной области где должна произойти отчистка.
sprite_clear_scr_addr:
	dw	0
	dw	0
; + Хранит 2 маски по 3 байта. 
; + Каждая маска должна примениться к отчистке области экрана.
clear_mask_bytes:
	db	0
	db	0
	db	0
	db	0
	db	0
	db	0


; + HL - clear screen address
clear:
	ld	bc,0 + 12 * 256
.loop:
	ld	(hl),c
	inc	l
	ld	(hl),c
	inc	l
	ld	(hl),c
	dec	l
	dec	l
	call	UTILS.down_hl
	djnz	.loop
	ret

collect_data_for_draw:

	ret

collect_data_for_clear:

	ret

draw_all_moving_sprites:
	ld	hl,(screen_addr_for_draw_sprite)
	ld	de,(sprite_addr_for_draw)
	call	RENDER.draw_sprite_24x16
	ld	hl,(screen_addr_for_draw_sprite + 2)
	ld	de,(sprite_addr_for_draw + 2)
	call	RENDER.draw_sprite_24x16
	ld	hl,(screen_addr_for_draw_sprite + 4)
	ld	de,(sprite_addr_for_draw + 4)
	jp	RENDER.draw_sprite_24x16

clear_all_moving_sprites:
	ld	hl,(sprite_clear_scr_addr)
	ld	de,(clear_mask_bytes)
	ld	a,(clear_mask_bytes + 2)
	ld	c,a
	call	clear_single_movable_sprite
	ld	hl,(sprite_clear_scr_addr + 2)
	ld	de,(clear_mask_bytes + 3)
	ld	a,(clear_mask_bytes + 5)
	ld	c,a

; + D - first mask byte for clear
; + E - second mask byte for clear
; + C - third mask byte for clear
; + HL - screen address for clear
clear_single_movable_sprite:
	ld	b,12
.loop:
	ld	a,(hl)
	and	d
	ld	(hl),a
	inc	l

	ld	a,(hl)
	and	e
	ld	(hl),a
	inc	l

	ld	a,(hl)
	and	c
	ld	(hl),a

	dec	l
	dec	l
	call	UTILS.down_hl
	djnz	.loop
	ret




	endmodule