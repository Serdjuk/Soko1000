        org 	#5CCB
basic:
        dw 	#00,endB - startLine
startLine:
	db 	#F9,#C0 		; RANDOMIZE USR
	db 	'23774'			; ADDR
	db 	#3A,#EA 		; : REM
	db 	#0E,#00,#00
	; ADDR value
	dw 	code
	db 	#00
code: 	; 23774
	LOAD_TAPE #4000, #1B00
	LOAD_TAPE endB, prog_end - prog_start
	
	call	RENDER.clear_screen
	ld	a,7
	call	RENDER.clear_attributes

	xor	a
	out	(#FE),a
	ld	hl,DATA.start
	ld	de,DATA.start + 1
	ld	bc,(DATA.end - DATA.start) - 1
	ld	(hl),a
	ldir

	; ld	hl,LEVEL_SELECTION.init
	ld	hl,MAIN_MENU.init
	ld	a,7
	ld	(DATA.level_color),a
	ld	sp,endB
	jp	loop
	db	"BY SERDJUK"
	; include	"../loop.asm"
	; jp	LEVEL_SELECTION.init

vars:
        db 	#0D
endB:

