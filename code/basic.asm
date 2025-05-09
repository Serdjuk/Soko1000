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
	ld	a,%00111111
	out	(#FE),a
	ld	hl,#5800
	ld	de,#5801
	ld	bc,#02FF
	ld	(hl),a
	ldir
	LOAD_TAPE #4000, #1B00
	LOAD_TAPE endB, prog_end - prog_start
	ld	a,100
	call	UTILS.pause
	call	MUSIC.play_music
.wait_any_key:
	call	UTILS.wait_any_key
	jr	z,.wait_any_key
	xor	a
	out	(#FE),a
	ld	hl,DATA.start
	ld	de,DATA.start + 1
	ld	bc,(DATA.end - DATA.start) - 1
	ld	(hl),a
	ldir
	call	RENDER.fade_out
	call	RENDER.clear_screen
	ld	a,7
	ld	(DATA.level_color),a
	ld	hl,MAIN_MENU.init
	ld	sp,endB
	jp	loop

vars:
        db 	#0D
endB:

