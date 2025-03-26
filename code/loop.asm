;	HL - jump address
loop:
	push	hl
	ld	hl,DATA.pressed_key
	ld	a,(hl)
	ld	(hl),0
	dec	hl
	ld	(hl),a
	pop	hl
	ei
	halt
	ld	bc,loop
	push	bc
	push	hl
	call	INPUT.keyListener
	ret
