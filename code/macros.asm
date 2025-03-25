	struct	OBJECT
type:		byte
x:		byte
y:		byte
pre_x:		byte
pre_y:		byte
	ends



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

; SAVE_PROGRESS:	macro
; 	ld	hl,#e000
; 	ld	ix,TEXT.progress_file_name
; 	call	#0970
; 	endm