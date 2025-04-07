	module 	GAME

	;	TODO - сделать модуль ANIMATION: (двежение спрайтов на 12 пикселей, моргание персонажа, блик по рандомной коробке)

init:

	ld	hl,DATA.LEVEL.cells
	ld	de,DATA.LEVEL.cells + 1
	ld	bc,#FF
	ld	(hl),l
	ldir

	ld	hl,(DATA.world_index)
	ld	a,l			; world id
	inc	hl
	ld	c,h			; level id
	call	CONVERT.get_level_address_hl
	call	CONVERT.depack
	call	CONVERT.offset_level_objects_positions
	call	GAME.set_pre_positions
	call 	RENDER.draw_level

	; отчистить буфер флагов определения конца уровня.
	ld	hl,DATA.buffer_flag_pressed
	ld	de,DATA.buffer_flag_pressed + 1
	ld	bc,5
	ld	(hl),0
	ldir

	call	LEVEL_INFO_PANEL.init
	ld	a,6
	call	RENDER.fade_in

start:
	call	update
	

	; check level completed
	ld	a,(DATA.direction)
	or	a
	jr	z,.end
	call	check_all_containers
	call	is_level_completed
	xor	a
	cp	b
	jr	nz,.end
	; level completed
	call	UTILS.set_progress
	LOOP	LEVEL_SELECTION.init

.end:
	xor	a
	ld	(DATA.direction),a

	LOOP 	start

update:
	call	input
	call	move
	call	set_pre_positions
	ret

set_pre_positions:
	ld	hl,DATA.LEVEL.cratesXY
	ld	de,DATA.pre_cratesXY
	
	ld	bc,14
	ldir
	ret
return_positions:
	ld	hl,DATA.pre_cratesXY
	ld	de,DATA.LEVEL.cratesXY
	ld	bc,14
	ldir
	ret

move:
	ld	a,(DATA.direction)
	or	a
	ret	z			; выход если не было задано движение.

	call	clear_objects

	call	draw_objects

	ret


draw_objects:
	call	RENDER.draw_level.draw_player

	ld	a,(DATA.LEVEL.crates)
	ld	b,a
	ld	de,DATA.LEVEL.cratesXY
	push	bc
.loop_crates:
	push	bc
	push	hl
	call	UTILS.get_screen_addr
	push	de
	ld	de,DATA.crate_sprite_buffer
	call	RENDER.draw_object_24x16
	pop	de
	pop	hl
	pop	bc
	inc	hl
	inc	hl
	djnz	.loop_crates

	pop	bc
	ld	de,DATA.LEVEL.containersXY
.loop_containers:
	push	bc
	push	hl
	call	UTILS.get_screen_addr
	push	de
	dec	de
	dec	de
	ld	a,(de)
	ld	de,SPRITE.container_anim_1
	call	RENDER.draw_object
	pop	de
	pop	hl
	pop	bc
	inc	hl
	inc	hl
	djnz	.loop_containers

	ret

clear_objects:

	ld	hl,DATA.LEVEL.playerXY
	ld	de,DATA.pre_playerXY
	call	.clear_sprite

	ld	a,(DATA.LEVEL.crates)
	ld	b,a
	ld	hl,DATA.LEVEL.cratesXY
	ld	de,DATA.pre_cratesXY
.loop:
	push	bc
	push	hl
	push	de
	call	.clear_sprite
	pop	de
	pop	hl
	pop	bc
	inc	hl
	inc	hl
	inc	de
	inc	de
	djnz	.loop
	ret

; + DE - sprite previous position address
; + HL - sprite position address
.clear_sprite:
	ld	a,(de)
	cp	(hl)
	jr	nz,.cl
	inc	hl
	inc	de
	ld	a,(de)
	cp	(hl)
	ret	z
	dec	hl
	dec	de
.cl:
	ld	a,(de)
	push	af
	call	UTILS.get_screen_addr
	ld	de,0b11110000
	pop	af
	rrca
	jp	c,RENDER.clear_sprite_12x12
	ld	de,0b00001111 * 256
	jp	RENDER.clear_sprite_12x12

input:
	ld	a,(DATA.direction)
	or	a
	ret	nz			; выход если движение игрока в процессе.
	
	ld	hl,DATA.LEVEL.playerXY
	ld	e,(hl)
	inc	hl
	ld	d,(hl)

	ld	c,DOWN
	call	INPUT.pressed_down
	jr	z,down
	sra	c
	call	INPUT.pressed_up
	jr	z,up
	sra	c
	call	INPUT.pressed_right
	jr	z,right
	sra	c
	call	INPUT.pressed_left
	jp	z,left
	xor	a
	ld	(DATA.direction),a
	ret
right:
	inc	e
	push	de
	call	UTILS.map_addr
	ld	a,(hl)
	or	a
	pop	de
	ret	nz			; спереди стена - движение запрещено.
	call	has_crate_on_position	; проверить нет ли коробки на пути.
	xor	a
	or	b
	jr	z,set_player_position	; движение свободно.
	inc	e
	push	de
	call	UTILS.map_addr
	ld	a,(hl)
	or	a
	pop	de
	ret	nz			; спереди коробки стена - движение запрещено.
	call	has_crate_on_position	; проверить нет ли коробки на пути после коробки.
	xor	a
	or	b
	ret	nz			; спереди коробки коробка - движение запрещено.
	ld	hl,(DATA.moving_crate_addr)
	ld	(hl),e			; устанавливаем коробке новую X координату.
	dec	e			; новый X игрока.
	jr	set_player_position
; + E - X
; + D - Y
; + save player position to HL (DATA.LEVEL.playerXY)
set_player_position:
	ld	hl,DATA.LEVEL.playerXY
	ld	(hl),e
	inc	hl
	ld	(hl),d
	ld	a,c
	ld	(DATA.direction),a
	ret
up:
	dec	d
	push	de
	call	UTILS.map_addr
	ld	a,(hl)
	or	a
	pop	de
	ret	nz			; спереди стена - движение запрещено.
	call	has_crate_on_position	; проверить нет ли коробки на пути.
	xor	a
	or	b
	jr	z,set_player_position	; движение свободно.
	dec	d
	push	de
	call	UTILS.map_addr
	ld	a,(hl)
	or	a
	pop	de
	ret	nz			; спереди коробки стена - движение запрещено.
	call	has_crate_on_position	; проверить нет ли коробки на пути после коробки.
	xor	a
	or	b
	ret	nz			; спереди коробки коробка - движение запрещено.
	ld	hl,(DATA.moving_crate_addr)
	inc	hl
	ld	(hl),d			; устанавливаем коробке новую Y координату.
	inc	d			; новый Y игрока.
	jr	set_player_position

down:
	inc	d
	push	de
	call	UTILS.map_addr
	ld	a,(hl)
	or	a
	pop	de
	ret	nz			; спереди стена - движение запрещено.
	call	has_crate_on_position	; проверить нет ли коробки на пути.
	xor	a
	or	b
	jr	z,set_player_position	; движение свободно.
	inc	d
	push	de
	call	UTILS.map_addr
	ld	a,(hl)
	or	a
	pop	de
	ret	nz			; спереди коробки стена - движение запрещено.
	call	has_crate_on_position	; проверить нет ли коробки на пути после коробки.
	xor	a
	or	b
	ret	nz			; спереди коробки коробка - движение запрещено.
	ld	hl,(DATA.moving_crate_addr)
	inc	hl
	ld	(hl),d			; устанавливаем коробке новую Y координату.
	dec	d			; новый Y игрока.
	jr	set_player_position
left:
	dec	e
	push	de
	call	UTILS.map_addr
	ld	a,(hl)
	or	a
	pop	de
	ret	nz			; спереди стена - движение запрещено.
	call	has_crate_on_position	; проверить нет ли коробки на пути.
	xor	a
	or	b
	jr	z,set_player_position	; движение свободно.
	dec	e
	push	de
	call	UTILS.map_addr
	ld	a,(hl)
	or	a
	pop	de
	ret	nz			; спереди коробки стена - движение запрещено.
	call	has_crate_on_position	; проверить нет ли коробки на пути.
	xor	a
	or	b
	ret	nz			; спереди коробки коробка - движение запрещено.
	ld	hl,(DATA.moving_crate_addr)
	ld	(hl),e			; устанавливаем коробке новую X координату.
	inc	e			; новый X игрока.
	jp	set_player_position

; + E - X
; + D - Y
; + return: B - if B == 0 {нет коробки на проверяемой позиции}
; + save: HL - адрес перемещаемой коробки, если она есть в (DATA.moving_crate_addr)
has_crate_on_position:
	ld	a,(DATA.LEVEL.crates)
	ld	b,a
	ld	hl,DATA.LEVEL.cratesXY
.loop:

	ld	a,e
	cp	(hl)
	inc	hl
	jr	z,.first_ok
.end:
	inc	hl
	djnz	.loop
	ret
.first_ok:
	ld	a,d
	cp	(hl)
	jr	nz,.end
	dec	hl
	ld	(DATA.moving_crate_addr),hl
	ret

; return: if B == 0 level completed else not completed
is_level_completed:
	ld	a,(DATA.LEVEL.crates)
	ld	b,a
	ld	hl,DATA.buffer_flag_pressed
.loop:
	ld	a,(hl)
	or	a
	ret	z
	inc	hl
	djnz	.loop
	ret

; + Проверяем все контейнеры на наличие на них ящиков.
check_all_containers:
	ld	a,(DATA.LEVEL.crates)
	ld	b,a
	ld	ix,DATA.buffer_flag_pressed
	ld	de,DATA.LEVEL.containersXY
.loop:
	push	bc
	push	af
	ld	b,a
	call	check_crate_on_container
	inc	de
	inc	de
	pop	af
	pop	bc
	djnz	.loop
	ret

; + DE - position address of container.
; + IX - buffer flag pressed address
; + B - crates count
; + return: ix + 1
; + проверка контейнера на наличие ящика на нем.
check_crate_on_container:
	ld	hl,DATA.LEVEL.cratesXY
.loop:
	ld	a,(de)
	cp	(hl)
	inc	hl
	inc	de
	jr	nz,.to_next_crate
	ld	a,(de)
	cp	(hl)
	jr	nz,.to_next_crate
	dec	de
	ld	(ix),1
	inc	ix
	ret
.to_next_crate:
	inc	hl
	dec	de
	djnz	.loop
	ld	(ix),0
	inc	ix
	ret

; + Обновляем прогресс обозначая текущий уровень в текущем мире как пройденный.
update_progress:
	ld	a,(DATA.world_index)
	ld	de,100
	call	UTILS.mul_de_a
	ld	a,(DATA.level_index)
	ld	c,a
	ld	b,d
	add	hl,bc		
	ld	bc,DATA.progress
	add	hl,bc
	ld	(hl),h			; значение кроме нуля обозначаает что уровень пройден.
	ret

	endmodule