	module	SPRITE

wall_01_left:				incbin "./graphics/wall_01_left.wbm", 4
wall_01_right:				incbin "./graphics/wall_01_right.wbm", 4

container_left:				incbin "./graphics/container_left.wbm", 4
container_right:			incbin "./graphics/container_right.wbm", 4




container_anim_1:			incbin "./graphics/container/container_01_left.wbm", 4
					incbin "./graphics/container/container_01_right.wbm", 4
container_anim_2:			incbin "./graphics/container/container_02_left.wbm", 4
					incbin "./graphics/container/container_02_right.wbm", 4

crate_v1:				incbin "./graphics/crates/crate_v1.wbm", 4
crate_v2:				incbin "./graphics/crates/crate_v2.wbm", 4
crate_v3:				incbin "./graphics/crates/crate_v3.wbm", 4

wall_01_v1:				incbin	"./graphics/walls/wall_01_v1.wbm", 4
wall_01_v2:				incbin	"./graphics/walls/wall_01_v2.wbm", 4
wall_02_v1:				incbin	"./graphics/walls/wall_02_v1.wbm", 4
wall_02_v2:				incbin	"./graphics/walls/wall_02_v2.wbm", 4
wall_03_v1:				incbin	"./graphics/walls/wall_03_v1.wbm", 4
wall_03_v2:				incbin	"./graphics/walls/wall_03_v2.wbm", 4
wall_04_v1:				incbin	"./graphics/walls/wall_04_v1.wbm", 4
wall_04_v2:				incbin	"./graphics/walls/wall_04_v2.wbm", 4
wall_05_v1:				incbin	"./graphics/walls/wall_05_v1.wbm", 4
wall_05_v2:				incbin	"./graphics/walls/wall_05_v2.wbm", 4
wall_06_v1:				incbin	"./graphics/walls/wall_06_v1.wbm", 4
wall_06_v2:				incbin	"./graphics/walls/wall_06_v2.wbm", 4
wall_07_v1:				incbin	"./graphics/walls/wall_07_v1.wbm", 4
wall_07_v2:				incbin	"./graphics/walls/wall_07_v2.wbm", 4
wall_08_v1:				incbin	"./graphics/walls/wall_08_v1.wbm", 4
wall_08_v2:				incbin	"./graphics/walls/wall_08_v2.wbm", 4
wall_09_v1:				incbin	"./graphics/walls/wall_09_v1.wbm", 4
wall_09_v2:				incbin	"./graphics/walls/wall_09_v2.wbm", 4
wall_10_v1:				incbin	"./graphics/walls/wall_10_v1.wbm", 4
wall_10_v2:				incbin	"./graphics/walls/wall_10_v2.wbm", 4

character:				incbin "./graphics/character/character.wbm", 4
character_blinking:			incbin "./graphics/character/character_blinking.wbm", 4
character_looking_up:			incbin "./graphics/character/character_looking_up.wbm", 4



frame_corner:				incbin "./graphics/frame/frame_corner.wbm", 4
frame_left:				incbin "./graphics/frame/frame_left.wbm", 4
frame_right:				incbin "./graphics/frame/frame_right.wbm", 4
frame_top:				incbin "./graphics/frame/frame_up.wbm", 4
frame_bottom:				incbin "./graphics/frame/frame_down.wbm", 4


	display "Sprites length: ",/A, $ - wall_01_left
	endmodule


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
; 
; 
; 
; 
; 
; 
; 
; 
; 