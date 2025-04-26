LOOP:	macro	adr
	ld	hl,adr
	ret	
	endm

LOAD_TAPE:	macro dst, length
	ld 	ix,dst
	ld 	de,length
	ld 	a,#FF
	scf
	call 	#0556
	endm

SAVE_TAPE:	macro dst, length
	ld 	ix,dst
	ld 	de,length
	ld 	a,#FF
	scf
	call 	#04C2
	endm
