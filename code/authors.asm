	module	AUTHORS
; 24 authors of 1000 levels.
; max name length: 21
MAX_LENGTH:	equ	21
all:
	db	"A1MASTER", 0
	db	"ALBERTO BORELLA", 0
	db	"ALBERTO GARCIA", 0
	db	"ANDREJ CERJAK", 0
	db	"AYMERIC DU PELOUX", 0
	db	"BLAZ NIKOLIC", 0
	db	"BRIAN KENT", 0
	db	"BUDDY CASAMIS", 0
	db	"DAVID BUCHWEITZ", 0
	db	"DAVID HOLLAND", 0
	db	"DAVID W SKINNER", 0
	db	"DRIES DE CLERCQ", 0
	db	"ERIC F TCHONG", 0
	db	"ERIM SEVER", 0
	db	"JACQUES DUTHEN [JACK]", 0
	db	"JORGE GLORIA", 0
	db	"MARTI HOMS CAUSSA", 0
	db	"MB", 0
	db	"PETER ASZTALOS", 0
	db	"SPIROS MANTZOUKIS", 0
	db	"THINKING RABBIT", 0
	db	"THOMAS REINKE", 0
	db	"YOSHIO MURASE", 0
	db	"ZXRETROSOFT", 0
	db	0
	display "Authors text length: ",/A, $ - all
	endmodule
