; half-row	DEC	HEX	BIN
; Space...B	32766	7FFE	01111111 11111110
; Enter...H	49150	BFFE	10111111 11111110
; P...Y		57342	DFFE	11011111 11111110
; 0...6		61438	EFFE	11101111 11111110
; 1...5		63486	F7FE	11110111 11111110
; Q...T		64510	FBFE	11111011 11111110
; A...G		65022	FDFE	11111101 11111110
; CS...V	65278	FEFE	11111110 11111110
	module 	INPUT

get_both_keys:
	ld	hl,(DATA.previous_pressed_key)
	ld	a,l
	or	a
	ret

pressed_right:
	call	get_both_keys
	ret	nz
	add	h
	ld	l,a
	ld	a,(VAR.key_binding + 3)
	cp	l
	ret

pressed_left:
	call	get_both_keys
	ret	nz
	add	h
	ld	l,a
	ld	a,(VAR.key_binding + 2)
	cp	l
	ret
pressed_down:
	call	get_both_keys
	ret	nz
	add	h
	ld	l,a
	ld	a,(VAR.key_binding + 1)
	cp	l
	ret
pressed_up:
	call	get_both_keys
	ret	nz
	add	h
	ld	l,a
	ld	a,(VAR.key_binding)
	cp	l
	ret

pressed_space:
	call	get_both_keys
	ret	nz
	add	h
	cp	SPACE
	ret
pressed_enter:
	call	get_both_keys
	ret	nz
	add	h
	cp	ENTER
	ret

; + C - key char
pressed_key:
	call	get_both_keys
	ret	nz
	add	h
	cp	c
	ret

keyListener:
	call getAKey
	ld a,r
	sub 3
	jr	z,l1   			; key not pressed	
	sub 4
	rra 
div5:
	rrc b
	jr nc,getChar
	sub 3
	jr div5
getChar:
	add a,low rows
	ld l,a
	adc a,high rows
	sub l
	ld h,a
	ld 	a,(hl)   		; received char (key)
l1:
	ld	(DATA.pressed_key),a
	ret
getAKey:
	ld   bc,#FEFE
	xor a
	ld r,a
nextRow
	in   a,(c) 
	cpl
	rrca
	ret c
	rrca
	ret c
	rrca
	ret c
	rrca
	ret c
	rrca
	ret c
	rlc  b
	jr c,nextRow
	ret
rows:   
	db "}ZXCV"
	db "ASDFG"
	db "QWERT"
	db "12345"
	db "09876"
	db "POIUY"
	db "{LKJH"
	db " `MNB"


kempston_joy:
	ld	a,(DATA.kempston_enable)
	or	a
	ret	z
	ld	hl,DATA.pressed_key
	in	a,(#1f)
	bit	1,a
	jr	nz,.left
	bit	0,a
	jr	nz,.right
	bit	3,a
	jr	nz,.up
	bit	2,a
	jr	nz,.down
	bit	4,a
	ret	z
.fire:
	ld	(hl),'0'
	ret
.left:
	ld	(hl),'6'
	ret
.right:
	ld	(hl),'7'
	ret
.up:
	ld	(hl),'9'
	ret
.down:
	ld	(hl),'8'
	ret

; + flasg Z as pressed
fire:
	ld	a,(VAR.key_binding + 4)
	ld	c,a
	jp	INPUT.pressed_key

	endmodule