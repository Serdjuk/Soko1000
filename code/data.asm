	module	DATA
start:
world_index:
		db	0
level_index:	
		db	0

BOM_player_direction:
		db	0
BOM_crate_id:
		db	0

player_sprite_buffer:
		block	3*16*8
crate_sprite_buffer:
		block	3*16*8
		
; + 0 Указывает на то что нужно выбирать мир.
; + !0 Указывает на то что нужно выбирать уровень в ранее выбранном мире.
is_world_selection_active:
		dw	0
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

			align	256
start_of_level_data:
walls_layer:				block 	256		; слой стен.
crates_layer:				block 	256		; слой коробок.
containers_layer:			block 	256		; слой контейнеров.
player_data:				block	Object
crates_data:				block	Object * MAX_CRATES
containers_data:			block	Object * MAX_CRATES
; + 2 байта - адрес экрана; 2 байта адрес маски
clear_data:				block	4 * 5	; 5 - максимум воможно перерисовать 5 объектов
; + 2 байта - адрес экрана; 2 байта адрес спрайта
draw_data:				block	4 * 5	; 5 - максимум воможно перерисовать 5 объектов

; + анимация 12 кадров (сдвигов) персонажа и/или коробки
; + устанавливаем значение 12 для начала анимации, каждый кадр значение должно уменьшаться.
; + когда значение = 0 - можно использовать управление, иначе управление отключено. 
animation:
					db	0

end_of_level_data:

		module	LEVEL
crates:			db	0		; кол-во коробок на уровне
width:			db	0		; ширинва уровня
height:			db	0		; высота уровня
	
offsetX:		db	0		; смещение уровня по X
offsetY:		db	0		; смещение уровня по Y
	
; containersXY:		block	12		; координаты шести контейнеров.
; cratesXY:		block	12		; координаты шести коробок.
; playerXY:		dw	0		; координаты игрока.


		endmodule

; + чередующийся бит для отрисовки уровня. Что бы понять, левый или правый спрайт отрисовывать при построении уровня.
rolling_x_bit:
		db	0
player_steps:
		dw	0
; + буфер 5ти значных чисел.
digital_value_buffer:			
		block	6	

growing_text_char_addresses:
		block	32 * 2 + 1
growing_text_scr_addresses:
		block	32 * 2 + 1
growing_bit
		db	0
growing_text_is_animate:
		db	0
growing_text_next_author:
		dw	0
level_color:	
		db	0
; + распакованные данные о прохождении уровней.
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