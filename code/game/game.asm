	module 	GAME

init:
	call	mute
	ld	hl,DATA.start_of_level_data
	ld	de,DATA.start_of_level_data + 1
	ld	bc,(DATA.end_of_level_data - DATA.start_of_level_data) - 1
	ld	(hl),l
	ldir

	ld	hl,(DATA.world_index)
	ld	a,l			; world id
	inc	hl
	ld	c,h			; level id
	call	CONVERT.get_level_address_hl
	call	CONVERT.depack
	call 	RENDER.draw_level

	call 	collect_containers_data

	call	LEVEL_INFO_PANEL.init

	
	call	set_level_color

start:



	call	redraw_objects
	call	draw_containers
	xor	a
	out	(#FE),a



	call	is_level_completed
	ld	a,b
	or	a
	jr	z,level_completed

	ld	a,(DATA.animation)
	or	a
	jr	z,.l1
	dec	a
	ld	(DATA.animation),a
.l1:

	ld	a,(DATA.animation)
	or	a
	call	z,input

	di
	call	set_objects_data_for_draw
	ld	iy,#5C3A
	ei

.end:

	LOOP 	start

level_completed:
	call	update_progress
	call	sound_completed
	;	play sound
	;	confirm window
	call	RENDER.fade_out

	LOOP	LEVEL_SELECTION.init

collect_containers_data:
	ld	ix,DATA.containers_data
	ld	hl,DATA.draw_containers_data
	ld	a,(DATA.LEVEL.crates)
	ld	b,a
.loop:
	push	bc
	push	hl
	ld	e,(ix + Object.X)
	ld	d,(ix + Object.Y)
	call	UTILS.get_screen_addr
	ex	de,hl
	pop	hl
	ld	(hl),e
	inc	hl
	ld	(hl),d
	inc	hl
	ex	de,hl

.spr_addr:
	ld	hl,SPRITE.container_left
	ld	a,(ix + Object.X)
	rrca
	jr	nc,.l1
	ld	bc,32
	add	hl,bc
.l1:
	ex	de,hl
	ld	(hl),e
	inc	hl
	ld	(hl),d
	inc	hl
	ld	bc,Object
	add	ix,bc
	pop	bc
	djnz	.loop
	ret

container_timer:
	db	8
draw_containers:
	; ld	a,(container_timer)
	; dec	a
	; ld	(container_timer),a
	; cp	4
	; ret	nc
	; or	a
	; jr	nz,.l1:

	; ld	a,8
	; ld	(container_timer),a
.l1:

	ld	hl,DATA.draw_containers_data
	ld	a,(DATA.LEVEL.crates)
	ld	b,a
.loop:
	push	bc
	ld	c,(hl)
	inc	hl
	ld	b,(hl)
	inc	hl
	ld	e,(hl)
	inc	hl
	ld	d,(hl)
	inc	hl
	push	hl
	ld	l,c
	ld	h,b
	call	RENDER.draw_sprite_16x16
	pop	hl
	pop	bc
	djnz	.loop
	ret

; + Очищаем направления движений всех объектов (даже не существующих) 1 игрока, 6 контейнеров и 6 коробок.
; + Отчистка должна происходить после анимации (после сдвига объектов на 12 пикселей)
clear_directions:
	push	bc
	push	de
	push	af
	ld	b,7			; игрок + 6 коробок. 6 контейнеров не могут быть сдвинуты и не стоит им очищать направление движения.
	xor	a
	ld	de,Object
	ld	hl,DATA.player_data + Object.DIRECTION
.loop:
	ld	(hl),a
	add	hl,de
	djnz	.loop
	pop	af
	pop	de
	pop	bc
	ret

redraw_objects:
	ld	a,(DATA.animation)
	or	a
	ret	z
	ld	hl,DATA.clear_data
	ld	b,5			; максимум 5 на отчистку
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
	ld	b,5			; максимум 5 на перерисовку. 
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

no_smooth:

	ld	iy,DATA.clear_data
	ld	ix,DATA.player_data
	
	ld	b,13
.l1:
	push	bc
	ld	a,(ix + Object.DIRECTION)
	or	a
	call	nz,set_objects_data_for_draw.set_clear_data
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
	call	nz,.set_draw_data

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
	ld	a,1
	ld	(DATA.animation),a
	ld	(iy),#FF
	ret

; + A - direction:
.set_draw_data:
	ld	e,(ix + Object.SHIFT_BIT)
	cp	3
	jr	nc,.no_shift_bit
	ld	a,e
	xor	4
	ld	e,a
	ld	(ix + Object.SHIFT_BIT),a
.no_shift_bit:
	ld	a,e
	call	UTILS.offset_of_sprite_buffer_hl
	ld	(iy + 2),l
	ld	(iy + 3),h
	ld	e,(ix + Object.X)
	ld	d,(ix + Object.Y)
	call	UTILS.get_screen_addr
	ld	(iy),l
	ld	(iy + 1),h
	ld	(ix + Object.SCR_ADDR),l
	ld	(ix + Object.SCR_ADDR + 1),h
	ld	bc,4
	add	iy,bc
	ret
.end:
	ret


set_objects_data_for_draw:
	ld	a,(DATA.animation)
	or	a
	ret	z
	ld	a,(DATA.smooth_motion)
	or	a
	jp	nz,no_smooth
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
	jr	z,.end			; FIX если контейнеры буду перерисовывать по тому же принцыпу, то этот переход не даст отрисовать контейнеры.
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

clear_play_area:
	ld	hl,#4000
	ld	bc,24 + 24 * 256
	ld	a,#00
	jp	RENDER.fill_scr_area

input:
	ld	de,(DATA.player_data)	; X,Y
	ld	bc,DOWN + #10 * 256	; B = 16 для сдвига по игровым слоям вверх/вниз; C - directon
	call	INPUT.pressed_down
	jp	z,to_down
	sra	c
	call	INPUT.pressed_up
	jp	z,to_up
	sra	c
	call	INPUT.pressed_right
	jp	z,to_right
	sra	c
	call	INPUT.pressed_left
	jp	z,to_left

	call	INPUT.pressed_space
	jr	z,BOM
	ld	c,'C'
	call	INPUT.pressed_key
	jp	z,change_level_color
	ld	c,'R'
	call	INPUT.pressed_key
	ld	hl,.restart_level
	ld	a,CONFIRM_RESTART_ID
	jp	z,GAME_MENU.confirmation_window
	ld	c,'E'
	call	INPUT.pressed_key
	ld	hl,.exit
	ld	a,CONFIRM_EXIT_ID
	jp	z,GAME_MENU.confirmation_window
	ld	c,'M'
	call	INPUT.pressed_key
	jr	z,.change_smooth
	ld	c,'I'
	call	INPUT.pressed_key
	ret	nz
	pop	af
	LOOP	GAME_MENU.init
.restart_level:
	; TODO - для рестарта уровня добавить окно подтверждения и очищать только игровую область.
	pop	af
	call	sound_restart
	call	RENDER.fade_out
	call	clear_play_area
	LOOP	init
.exit:
	pop	af
	call	sound_restart
	call	RENDER.fade_out
	call	RENDER.clear_screen
	LOOP	MAIN_MENU.init

.change_smooth:
	ld	a,(DATA.smooth_motion)
	xor	1
	ld	(DATA.smooth_motion),a
	ld	a,66
	out	(#FE),a
	ret

BOM:
	ld	a,(DATA.BOM_player_direction)
	or	a
	ret	z
	ld	ix,DATA.player_data
	ld	a,(ix + Object.DIRECTION)
	or	a
	ret	z
	ld	e,(ix + Object.X)
	ld	d,(ix + Object.Y)
	call	.swap_direction
	exx
	exa
	call	sound_move
	exa
	exx
	call	upgrade_obj_data.uod
	
	ld	bc,Object
.next_crate:
	add	ix,bc
	ld	a,(ix + Object.DIRECTION)
	or	a
	jr	z,.next_crate
	ld	e,(ix + Object.X)
	ld	d,(ix + Object.Y)
	push	de
	call	.swap_direction
	call	upgrade_obj_data.uod
	xor	a
	ld	(DATA.BOM_player_direction),a
	pop	de
	ld	hl,DATA.crates_layer
	call	UTILS.cell_addr
	ld	b,(hl)
	ld	(hl),0
	ld	a,(ix + Object.DIRECTION)
	ld	de,MAX_LEVEL_SIZE
	rrca	
	jr	c,.left
	rrca
	jr	c,.right
	rrca	
	jr	c,.up
	rrca	
	jr	c,.down
	ret
.left:
	dec	l
	ld	(hl),b
	ret
.right:
	inc	l
	ld	(hl),b
	ret
.up:
	or	a
	sbc	hl,de
	ld	(hl),b
	ret
.down:
	add	hl,de
	ld	(hl),b
	ret
.swap_direction:
	cp	3
	jr	nc,.vert
	xor	3			; swap left|right
	ld	c,a			; set swap direction
	sra	a
	sbc	0
	add	e
	ld	e,a
	ret
.vert:
	xor	12			; swap up|down
	ld	c,a			; set swap direction
	sra	a
	sra	a
	sra	a
	sbc	0
	add	d
	ld	d,a
	ret

to_left:
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
	call	clear_directions
	; обновляем данные коробки которая должна быть сдвинута
	ld	ix,DATA.crates_data
	dec	e
	dec	e
	call	upgrade_obj_data
	inc	e
	inc	e
	jr	.upgrade + 3
.upgrade:
	call	clear_directions
	dec	e
	ld	ix,DATA.player_data
	exx
	exa
	call	sound_cursor_move
	exa
	exx
	jr	upgrade_obj_data.uod

to_up:
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
	call	clear_directions
	; обновляем данные коробки которая должна быть сдвинута
	ld	ix,DATA.crates_data
	dec	d
	dec	d
	call	upgrade_obj_data
	inc	d
	inc	d
	jr	.upgrade + 3
.upgrade:
	call	clear_directions
	dec	d
	ld	ix,DATA.player_data
	exx
	exa
	call	sound_cursor_move
	exa
	exx
	jr	upgrade_obj_data.uod

; + A - object index
; + C - direction
; + E - X
; + D - Y
; + IX - objects map address
upgrade_obj_data:
	call	UTILS.obj_addr
.uod:
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
	call	clear_directions
	; обновляем данные коробки которая должна быть сдвинута
	ld	ix,DATA.crates_data
	inc	d
	inc	d
	call	upgrade_obj_data
	dec	d
	dec	d
	jr	.upgrade + 3
.upgrade:
	call	clear_directions
	inc	d
	ld	ix,DATA.player_data
	exx
	exa
	call	sound_cursor_move
	exa
	exx

	jr	upgrade_obj_data.uod

to_right:
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
	call	clear_directions
	; обновляем данные коробки которая должна быть сдвинута
	ld	ix,DATA.crates_data
	inc	e
	inc	e
	call	upgrade_obj_data
	dec	e
	dec	e
	jr	.upgrade + 3
.upgrade:
	call	clear_directions
	inc	e
	ld	ix,DATA.player_data
	exx
	exa
	call	sound_cursor_move
	exa
	exx

	jp	upgrade_obj_data.uod

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
	call	RENDER.paint_attr_rect
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
	ld	a,(DATA.animation)
	or	a
	ld	b,1
	ret	nz
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