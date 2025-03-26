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
	xor	a
	out	(#FE),a
	LOAD_TAPE #4000, #1B00
	LOAD_TAPE endB, prog_end - prog_start

	call	RENDER.clear_screen
	ld	hl,SPRITE.player_left
	ld	de,DATA.player_sprite_buffer
	call	UTILS.multiply_sprite_16x16_to_24x16
	ld	hl,SPRITE.crate_left
	ld	de,DATA.crate_sprite_buffer
	call	UTILS.multiply_sprite_16x16_to_24x16
	ld	hl,LEVEL_SELECTION.init
	ld	sp,endB
	jp	loop
	; include	"../loop.asm"
	; jp	LEVEL_SELECTION.init

vars:
        db 	#0D
endB:

