;	HL - jump address
loop:
	push	hl
	ld	hl,DATA.pressed_key
	ld	a,(hl)
	ld	(hl),0
	dec	hl
	ld	(hl),a
	pop	hl
	; ld 	iy,#5C3A
	ld	a,7
	out	(#FE),a
	ei
	halt
	ld	a,1
	out	(#FE),a
	ld	bc,loop
	push	bc
	push	hl
	call	INPUT.keyListener
	ret
