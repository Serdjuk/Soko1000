    	device zxspectrum48 : LABELSLIST "labList/user.l"

	if __ERRORS__ == 0
		struct	Object
X:			byte
Y:			byte
SHIFT_BIT:		byte
DIRECTION:		byte
SCR_ADDR:		word
CLEAR_SCR_ADDR:		word

		ends
		;
		include 	"macros.asm"
		include 	"def.asm"
		include 	"basic.asm"
		EMPTYTAP 	build/Soko1000.tap
		SAVETAP 	"build/Soko1000.tap", BASIC,"Soko1000", basic, endB-basic, 0
		TAPOUT 		build/Soko1000.tap
		incbin		"graphics/moroz1999 - Yanga (2021).scr"
		TAPEND
		
		
		org	endB
prog_start:
		TAPOUT 		build/Soko1000.tap


		include	"loop.asm"
		include	"render/render.asm"
		include "graphics/sprites.asm"
		include	"game/game.asm"
		include	"input/input.asm"
		include	"utils.asm"
		include	"converter/converter.asm"
		include	"packedLevels.asm"
		include	"menu/mainMenu.asm"
		include	"menu/gameMenu.asm"
		include	"levelInfoPanel.asm"
		include	"levelSelection/levelSelection.asm"
		include "levelInfoScreen.asm"
		include	"vars.asm"
		include	"text.asm"
		include	"authors.asm"

		tapend
prog_end:


		include	"data.asm"	; не включать в билд, там мусор изначально.

		display "Level cells: ",/A, DATA.walls_layer
		display "Shift sprites: ",/A, DATA.player_sprite_buffer
		display "level_indices_of_each_world: ",/A, DATA.level_indices_of_each_world
		display "PROGRESS ADDRESS: ",/A, DATA.progress
		display "LAST BYTE ADDR: ",/A, prog_end
		display "DATA LENGTH: ",/A,DATA.end - DATA.start
		display "FREE: ",/A, #FFFF - $



	endif