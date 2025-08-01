	module	CONGRATULATIONS
data:
	dw	done_frame1
	dw	done_frame2
	db	#00
max_duration:	equ	12
duration:
	db	0

init:
	xor	a
	; jr	$
	call	RENDER.clear_attributes
	call	grid
launch:
	ei
	halt
	call	animation
	LOOP	launch	

; + HL - data
draw:
	ld	de,#5800
	ld	bc,768
	ldir
	ret

animation:
	ld	a,(duration)
	inc	a
	cp	max_duration
	jr	nz,.continue
	call	get_data_addr
	call	draw
	xor	a	
.continue:
	ld	(duration),a
	ret
	
; + return: draw data addr
get_data_addr:
	ld	hl,data
	ld	a,(hl)
	or	a
	jr	nz,.continue
	ld	hl,data
.continue:
	ld	e,(hl)
	inc	hl
	ld	d,(hl)
	inc	hl
	ld	(get_data_addr + 1),hl
	ex	de,hl
	ret

grid:
	ld	hl,#4000
	ld	a,0b10101010
	ld	e,3
.third:
	ld	b,8
.line8:
	ld	c,0
	ld	(hl),a
	inc	hl
	inc	c
	jr	nz,.line8 + 2
	xor	#FF
	djnz	.line8
	dec	e
	ret	z
	jr	.third

	endmodule