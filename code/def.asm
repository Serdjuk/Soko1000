ENTER 					equ	'{'
CS					equ	'['
SS					equ	'/'
SPACE					equ	' '

; + максимальное количество миров.
MAX_WORLDS:				equ	10
; + максимальное количество уровней в одном мире.
MAX_LEVELS:				equ	100
; + максимальное кол-во коробок на уровне.
MAX_CRATES:				equ	6
; + максимално допустимый размер уровня: 16х16.
MAX_LEVEL_SIZE				equ 	#10

					; DIRECTIONS
STAY:					equ	0
LEFT:					equ	1
RIGHT:					equ	2
UP:					equ	4
DOWN:					equ	8