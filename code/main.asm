    	device zxspectrum48 : LABELSLIST "labList/user.l"


	if __ERRORS__ == 0
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
		include	"mainMenu/mainMenu.asm"
		include	"levelInfoPanel.asm"
		include	"levelSelection/levelSelection.asm"
		include "levelInfoScreen.asm"
		include	"vars.asm"
		include	"text.asm"

		tapend
prog_end:
		include	"data.asm"	; не включать в билд, там мусор изначально.

		display "Level cells: ",/A, DATA.LEVEL.cells
		display "Level crates count: ",/A, DATA.LEVEL.crates
		; display "Level crates positions: ",/A, DATA.LEVEL.cratesXY
		; display "Level container positions: ",/A, DATA.LEVEL.containersXY

		display "LAST BYTE ADDR: ",/A, prog_end
		display "LAST DATA ADDR: ",/A, $
		display "FREE: ",/A, #FFFF - $

		; display "crates addr: ",/A, DATA.LEVEL.cratesObjects
		; display "containers addr: ",/A, DATA.LEVEL.containersObjects

	endif