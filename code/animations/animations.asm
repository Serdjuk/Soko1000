	module	ANIMATIONS


; сдвиг спрайтов на 12 пикселей.
; Имеется таблица смещений Х на строке в экранной области: 0,1,3,4,6,7,9,10,12,13,15,16,18,19,21,22 (от левой стороны экрана)
; По ней мы вычисляем текущее смещение в строке на экране, допустим Х = 5, из таблицы получим 7.
; Если Х четное то отрисовывается спрайт без смещения, иначе отрисовывается спрайт со смещением на 4 пикселя вправо.
; Если имееются зараннее сдвинутые спрайты 8 штук 24х16:
; 	Индексы спрайтов при смещении вправо на 12 пикселей с четной позиции: 		1,2,3,4,5,6,7 | 0,1,2,3,4
; 	Индексы спрайтов при смещении вправо на 12 пикселей с не четной позиции: 	5,6,7 | 0,1,2,3,4,5,6,7 | 0
; 	Если индекс спрайта == 0, перемещаем спрайт на следующий символ и сбрасываем индекс спрайта на 0.
; 	При смещении влево перемещение на следующий символ так же если индекс спрайта == 0, но индексы в обратном порядке.
; 
; 

init:
	; создаем по 8 сдвинутых спрайтов для коробки и для персонажа.
	ld	hl,SPRITE.character
	ld	de,DATA.player_sprite_buffer
	call	UTILS.multiply_sprite_16x16_to_24x16
	; TODO сдлеать рандомный выбор коробок из существующих вариантов.
	ld	hl,SPRITE.crate_v2
	ld	de,DATA.crate_sprite_buffer
	call	UTILS.multiply_sprite_16x16_to_24x16

	ld	a,6
	call	RENDER.clear_attributes

update:
	ld	hl,(clear_addr)
	call	clear
	ld	hl,(crate_clear_addr)
	call	clear

	ld	a,(sprite_shift_bit)
	inc	a
	ld	(sprite_shift_bit),a



	ld	bc,DATA.player_sprite_buffer
	ld	de,(screen_addr)
	ld	ix,clear_addr
	call	move_right_to_12_px
	ld	(screen_addr),hl


	ld	bc,DATA.crate_sprite_buffer
	ld	de,(crate_screen_addr)
	ld	ix,crate_clear_addr
	call	move_right_to_12_px
	ld	(crate_screen_addr),hl


	LOOP	update

; TODO - sprite_shift_bit - нужно 2. потому ящик рядом стоящий с игроком будет иметь инвертированную четность. 
; Это означет что сдвиги спрайтов с начала движения у ящика и игрока будут разные. 0 и 4.
sprite_shift_bit:
	db	0
screen_addr:
	dw	#4000
clear_addr:
	dw	0

crate_screen_addr:
	dw	#4040
crate_clear_addr:
	dw	0


; + DE - sprite address
; + HL - screen address


; + A - sprite shift bit
; + BC - sprite buffer start address
; + DE - screen address
; + IX - ячейка памяти в который лежит экранный адрес отчистки спрайта.
; + return:
; + 	HL - screen address
; + Возвращаемы значениея нужно сохранитьпосле вызова процедуры.
; + HL - будет смещен каждые 8 сдвигов.
move_right_to_12_px:
	ld	a,(sprite_shift_bit)
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

	







	endmodule