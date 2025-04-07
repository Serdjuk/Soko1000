	module	DATA
start:
world_index:
		db	0
level_index:	
		db	0

player_sprite_buffer:
		block	3*16*8
crate_sprite_buffer:
		block	3*16*8
		
; + 0 Указывает на то что нужно выбирать мир.
; + !0 Указывает на то что нужно выбирать уровень в ранее выбранном мире.
is_world_selection_active:
		dw	0
; ; + Адрес таблицы указывающий на расположение курсора при выборе мира.
; world_cursor_table_addr:	
; 		dw	0
; + Адрес таблицы указывающий на расположение курсора при выборе уровня мира.
level_cursor_table_addr:	
		dw	0
previous_pressed_key:
		db	0
pressed_key:
		db	0


timer:
		dw	0
	
		; 	1 - 76 - не проходимый (2 ящика)


		module	LEVEL
	align	256
cells:		block 	256		; ячейки уровня.

crates:			db	0		; кол-во коробок на уровне
width:			db	0		; ширинва уровня
height:			db	0		; высота уровня
	
offsetX:		db	0		; смещение уровня по X
offsetY:		db	0		; смещение уровня по Y
	
containersXY:		block	12		; координаты шести контейнеров.
cratesXY:		block	12		; координаты шести коробок.
playerXY:		dw	0		; координаты игрока.


		endmodule

pre_cratesXY:	block	12
pre_playerXY:	dw	0

; + Тут хранится состояние прохождения уровня. Если кол-во подряд идущих значений = 1 и кол-во этих значений = кол-ву ящиков на уровне, то уровень пройден.
; + Каждый контейнер каждый ход чекает свою позицию со всем позициями ящиков, если есть совпадение, то записываем в буфер 1, иначе записываем 0.
buffer_flag_pressed:
		block	6

; + хранит адрес коордианат коробки которая будет сдвинута.
moving_crate_addr:			
		dw	0

; + чередующийся бит для отрисовки уровня. Что бы понять, левый или правый спрайт отрисовывать при построении уровня.
rolling_x_bit:
		db	0
player_steps:
		dw	0
; + буфер 5ти значных чисел.
digital_value_buffer:			
		block	6	

direction:
		db	0

level_paper:
		db	0
level_ink:	
		db	0

progress:		block	1000	; 1000 байт на 100 уровней. Каждый байт != 0 означает что уровень был пройден.


;	данные для сохранения
;-----------------------------------------------------
; + Таблица индексов уровней в каждом мире.
level_indices_of_each_world:
		block	MAX_WORLDS
; + 1000 бит на 1000 уровней. Каждый включенный бит означает что уровень был пройден.
compressed_progress:	
		block	125	
;-----------------------------------------------------


end:
	endmodule