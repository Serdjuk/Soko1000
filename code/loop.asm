;	HL - jump address
loop:
	ei
	halt
	ld	bc,loop
	push	bc
	push	hl
	ret
