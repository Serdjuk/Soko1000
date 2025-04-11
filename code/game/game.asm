	module 	GAME

init:

	ld	hl,DATA.start_of_level_data
	ld	de,DATA.start_of_level_data + 1
	ld	bc,DATA.end_of_level_data - DATA.start_of_level_data - 1
	ld	(hl),l
	ldir

	ld	hl,(DATA.world_index)
	ld	a,l			; world id
	inc	hl
	ld	c,h			; level id
	call	CONVERT.get_level_address_hl
	call	CONVERT.depack
	call 	RENDER.draw_level

	; отчистить буфер флагов определения конца уровня.
	; ld	hl,DATA.buffer_flag_pressed
	; ld	de,DATA.buffer_flag_pressed + 1
	; ld	bc,5
	; ld	(hl),0
	; ldir

	call	LEVEL_INFO_PANEL.init
	; ld	a,6
	; call	RENDER.fade_in



	ld	de,#4018
	ld	bc,8 + 24 * 256
	ld	hl,4 + %01001111 * 256
	call	RENDER.draw_frame
	
	call	set_level_color

start:



	call	redraw_objects


	ld	a,(DATA.animation)
	or	a
	call	z,is_level_completed
	ld	a,b
	or	a
	jr	z,level_completed

	ld	a,(DATA.animation)
	or	a
	jr	z,.l1
	dec	a
	ld	(DATA.animation),a
.l1:
	; check level completed
	ld	a,(DATA.animation)
	or	a
	call	z,input

	di
	call	set_objects_data_for_draw
	ld	iy,#5C3A
	ei


	; call	check_all_containers
	; call	is_level_completed
	; xor	a
	; cp	b
	; jr	nz,.end
	; ; level completed
	; call	UTILS.set_progress
	; LOOP	LEVEL_SELECTION.init




.end:

	LOOP 	start

level_completed:
	call	update_progress
	;	play sound
	;	confirm window
	call	RENDER.fade_out

	LOOP	LEVEL_SELECTION.init

; + Очищаем направления движений всех объектов (даже не существующих) 1 игрока, 6 контейнеров и 6 коробок.
; + Отчистка должна происходить после анимации (после сдвига объектов на 12 пикселей)
clear_directions:
	push	bc
	push	de
	ld	b,7			; игрок + 6 коробок. 6 контейнеров не могут быть сдвинуты и не стоит им очищать направление движения.
	xor	a
	ld	de,Object
	ld	hl,DATA.player_data + Object.DIRECTION
.loop:
	ld	(hl),a
	add	hl,de
	djnz	.loop
	pop	de
	pop	bc
	ret

redraw_objects:
	ld	a,(DATA.animation)
	or	a
	ret	z
	ld	hl,DATA.clear_data
	ld	b,5			; максимум 5 на отчистку или 5 на перерисовку. 
.loop:
	ld	a,(hl)
	cp	#FF
	jr	z,.draw
	push	bc
	push	hl
	ld	e,a
	inc	hl
	ld	d,(hl)
	inc	hl
	ld	a,(hl)
	inc	hl
	ld	h,(hl)
	ld	l,a
	ex	de,hl
	call	RENDER.clear_sprite_24x12
	pop	hl
	inc	hl
	inc	hl
	inc	hl
	inc	hl
	pop	bc
	djnz	.loop
.draw:
	ld	hl,DATA.draw_data
	ld	b,5			; максимум 5 на отчистку или 5 на перерисовку. 
.l2:
	ld	a,(hl)
	cp	#FF
	ret	z
	push	bc
	push	hl
	ld	e,a
	inc	hl
	ld	d,(hl)
	inc	hl
	ld	a,(hl)
	inc	hl
	ld	h,(hl)
	ld	l,a
	ex	de,hl
	call	RENDER.draw_sprite_24x16
.skip:
	pop	hl
	inc	hl
	inc	hl
	inc	hl
	inc	hl
	pop	bc
	djnz	.l2

	ret

set_objects_data_for_draw:
	ld	a,(DATA.animation)
	or	a
	ret	z
	ld	b,13
	xor	a
	ld	ix,DATA.player_data
	ld	iy,DATA.clear_data
.l1:
	push	bc
	ld	a,(ix + Object.DIRECTION)
	or	a
	call	nz,.set_clear_data
	ld	bc,Object
	add	ix,bc
	pop	bc
	djnz	.l1
	ld	(iy),#FF

	ld	iy,DATA.draw_data
	ld	ix,DATA.player_data
	ld	bc,DATA.player_sprite_buffer
	ld	a,(ix + Object.DIRECTION)
	or	a
	jr	z,.end
	call	.set_draw_data

	ld	iy,DATA.draw_data + 4
	ld	ix,DATA.crates_data
	ld	b,6			; 6 коробок
.l2:
	push	bc
	ld	a,(ix + Object.DIRECTION)
	or	a
	ld	bc,DATA.crate_sprite_buffer
	call	nz,.set_draw_data
	ld	bc,Object
	add	ix,bc
	pop	bc
	djnz	.l2
.end:
	ld	(iy),#FF
	ret

.set_clear_data:
	ld	a,(ix + Object.SHIFT_BIT)
	and	7
	ld	c,a
	rlca
	add	c
	ld	c,a
	ld	b,0
	ld	hl,SPRITE.clear_mask_24x16
	add	hl,bc
	ld	(iy + 2),l
	ld	(iy + 3),h
	ld	a,(ix + Object.SCR_ADDR)
	ld	(iy),a
	ld	a,(ix + Object.SCR_ADDR + 1)
	ld	(iy + 1),a
	ld	bc,4
	add	iy,bc
	ret




	;	TODO	сделать для всех направлений, для всех объектов,
	;	TODO	возможно сделать еще прослойку для сбора всех координат для отчистки и отрисовки.
	
; + A - direction
.set_draw_data:
	rrca
	jr	c,.left
	rrca
	jr	c,.right
	rrca
	jr	c,.up
	rrca
	ret	nc

.down:
	call	.copy_scr_addr
	call	UTILS.down_hl
.d_set:
	ld	(ix + Object.SCR_ADDR),l
	ld	(ix + Object.SCR_ADDR + 1),h
	ld	a,(ix + Object.SHIFT_BIT)
	jr	.set_scrren_and_sprite_addr
.left:
	call	.copy_scr_addr
	dec	a
	and	7
	ld	(ix + Object.SHIFT_BIT),a
	cp	7
	jr	nz,.set_scrren_and_sprite_addr
	dec	l
	ld	(ix + Object.SCR_ADDR),l
	; jr	.set_scrren_and_sprite_addr
.set_scrren_and_sprite_addr:
	ld	(iy),l
	ld	(iy + 1),h
	call	UTILS.offset_of_sprite_buffer_hl
	ld	(iy + 2),l
	ld	(iy + 3),h
	ld	bc,4
	add	iy,bc
	ret
.up:
	call	.copy_scr_addr
	call	UTILS.up_hl
	jr	.d_set
.right:
	call	.copy_scr_addr
	inc	a
	and	7
	ld	(ix + Object.SHIFT_BIT),a
	jr	nz,.set_scrren_and_sprite_addr
	inc	l
	ld	(ix + Object.SCR_ADDR),l
	jr	.set_scrren_and_sprite_addr

; + IX - object data
; + return: A - SHIFT_BIT; HL - screen address
.copy_scr_addr:
	ld	a,(ix + Object.SCR_ADDR)
	ld	l,a
	ld	(ix + Object.CLEAR_SCR_ADDR),a
	ld	a,(ix + Object.SCR_ADDR + 1)
	ld	h,a
	ld	(ix + Object.CLEAR_SCR_ADDR + 1),a
	ld	a,(ix + Object.SHIFT_BIT)
	ret

input:
	ld	de,(DATA.player_data)	; X,Y
	ld	bc,DOWN + #10 * 256	; B = 16 для сдвига по игровым слоям вверх/вниз; C - directon
	call	INPUT.pressed_down
	jp	z,to_down
	sra	c
	call	INPUT.pressed_up
	jr	z,to_up
	sra	c
	call	INPUT.pressed_right
	jp	z,to_right
	sra	c
	call	INPUT.pressed_left
	jr	z,to_left

	call	INPUT.pressed_space
	jr	z,BOM
	call	INPUT.pressed_level_color
	jp	z,change_level_color
	ret
BOM:






	;	TODO - как коробку заставить сделать шаг назад ?








	ld	a,(DATA.BOM_player_direction)
	ld	hl,.reset_BOM
	push	hl
	rrca	
	ld	c,RIGHT
	jp	c,to_right
	rrca	
	ld	c,LEFT
	jr	c,to_left
	rrca	
	ld	c,DOWN
	jp	c,to_down
	rrca	
	ld	c,UP
	jr	c,to_up
	pop	hl
	ret
.reset_BOM:
	xor	a
	ld	(DATA.BOM_player_direction),a
	ret
to_left:
	call	clear_directions
	ld	hl,DATA.walls_layer
	call	UTILS.cell_addr
	dec	l			; ячейка слева
	xor	a
	cp	(hl)
	ret	nz			; слева стена
	inc	h			; переключились на слой коробок
	cp	(hl)
	jr	z,.upgrade		; слева пусто - можно двигаться.
	dec	l			; ячейка слева от коробки
	cp	(hl)
	ret	nz			; слева от коробки коробка
	dec	h			; переключаем на слой стен
	cp	(hl)
	ret	nz			; слева от кробки стена
	inc	h			; возвращаем слой коробок
	inc	l			; возвращаем ячейку с коробкой
	; сдвигаем коробку на слое коробок влево
	
	ld	a,(hl)
	ld	(hl),0
	dec	l
	ld	(hl),a
	; обновляем данные коробки которая должна быть сдвинута
	ld	ix,DATA.crates_data
	dec	e
	dec	e
	call	upgrade_obj_data
	inc	e
	inc	e
.upgrade:
	dec	e
	ld	ix,DATA.player_data
	jr	upgrade_obj_data + 3

to_up:
	call	clear_directions
	ld	hl,DATA.walls_layer
	call	UTILS.cell_addr
	ld	a,l
	sub	b
	ld	l,a
	xor	a
	cp	(hl)
	ret	nz			; сверху стена
	inc	h			; переключились на слой коробок
	cp	(hl)
	jr	z,.upgrade		; сверху пусто - можно двигаться.
	ld	a,l
	sub	b
	ld	l,a
	xor	a
	cp	(hl)
	ret	nz			; сверху коробки коробка
	dec	h			; переключаем на слой стен
	cp	(hl)
	ret	nz			; сверху кробки стена
	inc	h			; возвращаем слой коробок
	push	hl
	ld	a,l			
	add	b
	ld	l,a			; возвращаем ячейку с коробкой
	ld	a,(hl)
	ld	(hl),0
	pop	hl
	ld	(hl),a
	; обновляем данные коробки которая должна быть сдвинута
	ld	ix,DATA.crates_data
	dec	d
	dec	d
	call	upgrade_obj_data
	inc	d
	inc	d
.upgrade:
	dec	d
	ld	ix,DATA.player_data
	jr	upgrade_obj_data + 3

; + A - object index
; + C - direction
; + E - X
; + D - Y
; + IX - objects map address
upgrade_obj_data:
	call	UTILS.obj_addr
	; ld	b,0
	ld	(ix + Object.DIRECTION),c
	ld	a,c
	ld	(DATA.BOM_player_direction),a
	ld	(ix + Object.X),e
	ld	(ix + Object.Y),d
	ld	a,(ix + Object.SCR_ADDR)
	ld	(ix + Object.CLEAR_SCR_ADDR),a
	ld	a,(ix + Object.SCR_ADDR + 1)
	ld	(ix + Object.CLEAR_SCR_ADDR + 1),a
	ld	a,12
	ld	(DATA.animation),a
	ret
to_down:
	call	clear_directions
	ld	hl,DATA.walls_layer
	call	UTILS.cell_addr
	
	ld	a,l
	add	b
	ld	l,a
	xor	a
	cp	(hl)
	ret	nz			; снизу стена
	inc	h			; переключились на слой коробок
	cp	(hl)
	jr	z,.upgrade		; снизу пусто - можно двигаться.
	ld	a,l
	add	b
	ld	l,a
	xor	a
	cp	(hl)
	ret	nz			; снизу коробки коробка
	dec	h			; переключаем на слой стен
	cp	(hl)
	ret	nz			; снизу кробки стена
	inc	h			; возвращаем слой коробок
	push	hl
	ld	a,l			
	sub	b
	ld	l,a			; возвращаем ячейку с коробкой
	ld	a,(hl)
	ld	(hl),0
	pop	hl
	ld	(hl),a
	; обновляем данные коробки которая должна быть сдвинута
	ld	ix,DATA.crates_data
	inc	d
	inc	d
	call	upgrade_obj_data
	dec	d
	dec	d
.upgrade:
	inc	d
	ld	ix,DATA.player_data
	jr	upgrade_obj_data + 3

to_right:
	call	clear_directions
	ld	hl,DATA.walls_layer
	call	UTILS.cell_addr
	inc	l			; ячейка спереди
	xor	a
	cp	(hl)
	ret	nz			; спереди стена
	inc	h			; переключились на слой коробок
	cp	(hl)
	jr	z,.upgrade		; спереди пусто - можно двигаться.
	inc	l			; ячейка спереди коробки
	cp	(hl)
	ret	nz			; спереди коробки коробка
	dec	h			; переключаем на слой стен
	cp	(hl)
	ret	nz			; спереди кробки стена
	inc	h			; возвращаем слой коробок
	dec	l			; возвращаем ячейку с коробкой
	; сдвигаем коробку на слое коробок вправо

	ld	a,(hl)
	ld	(hl),0
	inc	l
	ld	(hl),a
	; обновляем данные коробки которая должна быть сдвинута
	ld	ix,DATA.crates_data
	inc	e
	inc	e
	call	upgrade_obj_data
	dec	e
	dec	e
.upgrade:
	inc	e
	ld	ix,DATA.player_data
	jp	upgrade_obj_data + 3


; right:
; 	inc	e			; X + 1
; 	call	UTILS.map_addr		; HL - адрес ячейки справа от персонажа
; 	ld	a,(hl)
; 	or	a
; 	ret	nz			; спереди стена - движение запрещено.
; 	call	has_crate_on_position	; проверить нет ли коробки на пути.
; 	xor	a
; 	or	b
; 	jr	z,set_player_position	; движение свободно.
; 	inc	e			; X + 1
; 	inc	l			; смещаем адрес ячейки еще на + 1 от персонажа (в случае если нужно проверить можно ли сдвинуть ящик перед персонажем) 
; 	ld	a,(hl)
; 	or	a
; 	ret	nz			; спереди коробки стена - движение запрещено.
; 	call	has_crate_on_position	; проверить нет ли коробки на пути после коробки.
; 	xor	a
; 	or	b
; 	ret	nz			; спереди коробки коробка - движение запрещено.
; 	ld	hl,(DATA.moving_crate_addr)
; 	ld	(hl),e			; устанавливаем коробке новую X координату.
; 	dec	e			; новый X игрока.
; 	jr	set_player_position
; ; + E - X
; ; + D - Y
; ; + save player position to HL (DATA.LEVEL.playerXY)
; set_player_position:
; 	ld	hl,DATA.LEVEL.playerXY
; 	ld	(hl),e
; 	inc	hl
; 	ld	(hl),d
; 	ld	a,c
; 	ld	(DATA.direction),a
; 	ret
; up:
; 	dec	d
; 	push	de
; 	call	UTILS.map_addr
; 	ld	a,(hl)
; 	or	a
; 	pop	de
; 	ret	nz			; спереди стена - движение запрещено.
; 	call	has_crate_on_position	; проверить нет ли коробки на пути.
; 	xor	a
; 	or	b
; 	jr	z,set_player_position	; движение свободно.
; 	dec	d
; 	push	de
; 	call	UTILS.map_addr
; 	ld	a,(hl)
; 	or	a
; 	pop	de
; 	ret	nz			; спереди коробки стена - движение запрещено.
; 	call	has_crate_on_position	; проверить нет ли коробки на пути после коробки.
; 	xor	a
; 	or	b
; 	ret	nz			; спереди коробки коробка - движение запрещено.
; 	ld	hl,(DATA.moving_crate_addr)
; 	inc	hl
; 	ld	(hl),d			; устанавливаем коробке новую Y координату.
; 	inc	d			; новый Y игрока.
; 	jr	set_player_position

; down:
; 	inc	d
; 	push	de
; 	call	UTILS.map_addr
; 	ld	a,(hl)
; 	or	a
; 	pop	de
; 	ret	nz			; спереди стена - движение запрещено.
; 	call	has_crate_on_position	; проверить нет ли коробки на пути.
; 	xor	a
; 	or	b
; 	jr	z,set_player_position	; движение свободно.
; 	inc	d
; 	push	de
; 	call	UTILS.map_addr
; 	ld	a,(hl)
; 	or	a
; 	pop	de
; 	ret	nz			; спереди коробки стена - движение запрещено.
; 	call	has_crate_on_position	; проверить нет ли коробки на пути после коробки.
; 	xor	a
; 	or	b
; 	ret	nz			; спереди коробки коробка - движение запрещено.
; 	ld	hl,(DATA.moving_crate_addr)
; 	inc	hl
; 	ld	(hl),d			; устанавливаем коробке новую Y координату.
; 	dec	d			; новый Y игрока.
; 	jr	set_player_position
; left:
; 	dec	e
; 	call	UTILS.map_addr
; 	ld	a,(hl)
; 	or	a
; 	ret	nz			; спереди стена - движение запрещено.
; 	call	has_crate_on_position	; проверить нет ли коробки на пути.
; 	xor	a
; 	or	b
; 	jr	z,set_player_position	; движение свободно.
; 	dec	e
; 	dec	l
; 	ld	a,(hl)
; 	or	a
; 	ret	nz			; спереди коробки стена - движение запрещено.
; 	call	has_crate_on_position	; проверить нет ли коробки на пути.
; 	xor	a
; 	or	b
; 	ret	nz			; спереди коробки коробка - движение запрещено.
; 	ld	hl,(DATA.moving_crate_addr)
; 	ld	(hl),e			; устанавливаем коробке новую X координату.
; 	inc	e			; новый X игрока.
; 	jp	set_player_position

; ; + E - X
; ; + D - Y
; ; + return: B - if B == 0 {нет коробки на проверяемой позиции}
; ; + save: HL - адрес перемещаемой коробки, если она есть в (DATA.moving_crate_addr)
; has_crate_on_position:
; 	push	hl
; 	ld	a,(DATA.LEVEL.crates)
; 	ld	b,a
; 	ld	hl,DATA.LEVEL.cratesXY
; .loop:

; 	ld	a,e
; 	cp	(hl)
; 	inc	hl
; 	jr	z,.first_ok
; .end:
; 	inc	hl
; 	djnz	.loop
; 	pop	hl
; 	ret
; .first_ok:
; 	ld	a,d
; 	cp	(hl)
; 	jr	nz,.end
; 	dec	hl
; 	ld	(DATA.moving_crate_addr),hl
; 	pop	hl
; 	ret


change_level_color:
	ld	a,(DATA.level_color)
	inc	a
	and	7
	jr	nz,.l1
	inc	a
.l1:
	ld	(DATA.level_color),a

set_level_color:
	ld	hl,#5800
	ld	d,12
	ld	a,(DATA.level_color)
	ld	bc,#18+#18*256
.loop:
	push	de
	push	bc
	push	hl
	call	RENDER.paint_rect
	pop	hl
	ld	bc,33
	add	hl,bc
	pop	bc
	dec	c
	dec	c
	dec	b
	dec	b
	pop	de
	dec	d
	halt
	jr	nz,.loop
	ret


; + return: if B == 0 level completed else not completed
is_level_completed:
	ld	hl,DATA.containers_data
	ld	a,(DATA.LEVEL.crates)
	ld	b,a

.loop:
	push	bc
	push	hl

	ld	e,(hl)
	inc	hl
	ld	d,(hl)
	ld	hl,DATA.crates_layer
	call	UTILS.cell_addr
	ld	a,(hl)
	or	a
	jr	z,.skip_stack
	pop	hl
	ld	bc,Object
	add	hl,bc
	pop	bc
	djnz	.loop
	ret
.skip_stack:
	pop	hl
	pop	bc
	ret

; + Проверяем все контейнеры на наличие на них ящиков.
; check_all_containers:
; 	ld	a,(DATA.LEVEL.crates)
; 	ld	b,a
; 	ld	ix,DATA.buffer_flag_pressed
; 	ld	de,DATA.LEVEL.containersXY
; .loop:
; 	push	bc
; 	push	af
; 	ld	b,a
; 	call	check_crate_on_container
; 	inc	de
; 	inc	de
; 	pop	af
; 	pop	bc
; 	djnz	.loop
; 	ret

; + DE - position address of container.
; + IX - buffer flag pressed address
; + B - crates count
; + return: ix + 1
; + проверка контейнера на наличие ящика на нем.
; check_crate_on_container:
; 	ld	hl,DATA.LEVEL.cratesXY
; .loop:
; 	ld	a,(de)
; 	cp	(hl)
; 	inc	hl
; 	inc	de
; 	jr	nz,.to_next_crate
; 	ld	a,(de)
; 	cp	(hl)
; 	jr	nz,.to_next_crate
; 	dec	de
; 	ld	(ix),1
; 	inc	ix
; 	ret
; .to_next_crate:
; 	inc	hl
; 	dec	de
; 	djnz	.loop
; 	ld	(ix),0
; 	inc	ix
; 	ret

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