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
keyListener:
	call getAKey
	ld a,r
	sub 3
	ret z   ; key not pressed
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
	;   ld l,a
	;   ld h,0
	;   ld bc,rows
	;   add hl,bc
	ld a,(hl)   ; received char (key)
	// .....
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
	endmodule