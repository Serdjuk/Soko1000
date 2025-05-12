ENTER 					equ	'{'
CS					equ	'['
SS					equ	'/'
SPACE					equ	' '

BRIGHT:					equ	%01000000

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


SWL_WORLD_SCR_ADDR:			equ	#4022
SWL_WORLD_ATTR_ADDR:			equ	#5822
SWL_LEVEL_SCR_ADDR:			equ	#4029
SWL_LEVEL_ATTR_ADDR:			equ	#5829

SWL_WORLD_FRAME_COLOR:					equ	Color.YELLOW
SWL_WORLD_FRAME_SELECTED_COLOR:				equ	Color.YELLOW or BRIGHT
SWL_LEVEL_FRAME_COLOR:					equ	Color.YELLOW
SWL_LEVEL_FRAME_SELECTED_COLOR:				equ	Color.YELLOW or BRIGHT

SWL_WORLD_FIELD_SELECTED_COLOR:				equ	Color.BLACK or (Color.WHITE << 3) or BRIGHT
SWL_WORLD_FIELD_UNSELECTED_COLOR:			equ	Color.BLACK or (Color.WHITE << 3)
SWL_WORLD_FIELD_SELECTED_CURSOR_COLOR:			equ	Color.WHITE or (Color.BLUE << 3) or BRIGHT
SWL_WORLD_FIELD_UNSELECTED_CURSOR_COLOR:		equ	Color.WHITE or (Color.BLUE << 3)

SWL_LEVEL_FIELD_SELECTED_COLOR:				equ	Color.BLACK or (Color.WHITE << 3) or BRIGHT
SWL_LEVEL_FIELD_SELECTED_COMPLETED_COLOR:		equ	Color.GREEN or (Color.WHITE << 3) or BRIGHT
SWL_LEVEL_FIELD_SELECTED_CURSOR_COLOR:			equ	Color.WHITE or (Color.BLUE << 3) or BRIGHT
SWL_LEVEL_FIELD_SELECTED_CURSOR_COMPLETED_COLOR:	equ	Color.GREEN or (Color.BLUE << 3) or BRIGHT
SWL_LEVEL_FIELD_UNSELECTED_COLOR:			equ	Color.BLACK or (Color.WHITE << 3) 
SWL_LEVEL_FIELD_UNSELECTED_COMPLETED_COLOR:		equ	Color.GREEN or (Color.WHITE << 3)
SWL_LEVEL_FIELD_UNSELECTED_CURSOR_COLOR:		equ	Color.WHITE or (Color.BLUE << 3) 
SWL_LEVEL_FIELD_UNSELECTED_CURSOR_COMPLETED_COLOR:	equ	Color.GREEN or (Color.BLUE << 3) 


CONTAINER_ANIMATION_FRAMES:				equ	2
