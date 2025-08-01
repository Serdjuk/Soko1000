LOOP:	macro	adr
	ld	hl,adr
	ret	
	endm

LOAD_TAPE:	macro dst, length
	ld	(Errlod+1),sp
Errlod	ld	de,#0000
	dec	de
	dec	de
	ld	(#5C3D),de
	ld 	ix,dst
	ld 	de,length
	ld 	a,#FF
	scf
	call 	#0556
	endm

SAVE_TAPE:	macro dst, length
	ld	(Errsav+1),sp
Errsav	ld	de,#0000
	dec	de
	dec	de
	ld	(#5C3D),de
	ld 	ix,dst
	ld 	de,length
	ld 	a,#FF
	scf
	call 	#04C2
	endm
