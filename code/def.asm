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

FONT_NORMAL				equ	1
FONT_BOLD				equ	2
FONT_ITALIC_HALF_BOLD			equ	4
FONT_ZEBRA				equ	8

; + количество пунктов в главного меню		
MAIN_MENU_ITEMS_COUNT:			equ	(VAR.selected_attr_addr.end - VAR.selected_attr_addr) / 2


CONFIRM_EXIT_ID:			equ	1
CONFIRM_RESTART_ID:			equ	2