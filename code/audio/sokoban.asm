
	; org #8000

	;test code
	module	MUSIC

play_music:
	ld	(.end + 1),sp
	ld 	hl,music_data
	call 	play
.end:
	ld	sp,0
	ret
	
	
	
	;engine code

;SquatM by Shiru, 08'21 (minor mods for the original Squat 06'17)
;Squeeker like, just without the output value table
;4 channels of tone with different duty cycle
;sample drums, non-interrupting
;customizeable noise percussion, interrupting


;music data is all 16-bit words, first control then a few optional ones

;control word is PSSSSSSS DDDN4321, where P=percussion,S=speed, D=drum, N=noise mode, 4321=channels
;D triggers non-interruping sample drum
;P trigger
;if 1, channel 1 freq follows
;if 2, channel 2 freq follows
;if 3, channel 3 freq follows
;if 4, channel 4 freq follows
;if N, channel 4 mode follows, it is either #0000 (normal) or #04cb (noise)
;if P, percussion follows, LSB=volume, MSB=pitch



RLC_H=#04cb			;to enable noise mode
NOP_2=#0000			;to disable noise mode
RLC_HL=#06cb		;to enable sample reading
ADD_IX_IX=#29dd		;to disable sample reading


play

	di
	
	ld e,(hl)
	inc hl
	ld d,(hl)
	inc hl
	ld (pattern_ptr),de
	
	ld e,(hl)
	inc hl
	ld d,(hl)
	
	ld (loop_ptr),de

	dec hl
	ld (sample_list),hl
	
	ld hl,ADD_IX_IX
	ld (sample_read),hl
	ld hl,NOP_2					;normal mode
	ld (noise_mode),hl
	
	ld ix,0						;needs to be 0 to skip sample reading

	ld c,0
	exx
	ld de,#0808					;sample bit counter and reload value

play_loop

pattern_ptr=$+1
	ld sp,0
	
return_loop

	pop bc						;control word
								;B=duration of the row (0=loop)
								;C=flags DDDN4321 (Drum, Noise, 1-4 channel update)
	ld a,b
	or a
	jp nz,no_loop
	
loop_ptr=$+1
	ld sp,0
	
	jp return_loop
	
no_loop

	ld a,c
	
	rra
	jr nc,skip_note_0
	
	pop hl
	ld (ch0_add),hl
	
skip_note_0

	rra
	jr nc,skip_note_1

	pop hl
	ld (ch1_add),hl
	
skip_note_1

	rra
	jr nc,skip_note_2
	
	pop hl
	ld (ch2_add),hl
	
skip_note_2

	rra
	jr nc,skip_note_3
	
	pop hl
	ld (ch3_add),hl
	
skip_note_3

	rra
	jr nc,skip_mode_change
	
	pop hl						;nop:nop or rlc h
	ld (noise_mode),hl

skip_mode_change

	and 7
	jp z,skip_drum
	
sample_list=$+1
	ld hl,0						;sample_list-2
	add a,a
	add a,l
	ld l,a
	ld a,(hl)
	inc l
	ld h,(hl)
	ld l,a
	ld (sample_ptr),hl
	ld hl,RLC_HL
	ld (sample_read),hl

skip_drum

	bit 7,b						;check percussion flag
	jp z,skip_percussion

	res 7,b						;clear percussion flag

	ld (noise_bc),bc
	ld (noise_de),de

	pop hl						;read percussion parameters

	ld a,l						;noise volume
	ld (noise_volume),a
	ld b,h						;noise pitch
	ld c,h
	ld de,#2174					;utz's rand seed			
	exx
	ld bc,429					;noise duration, takes as long as inner sound loop

noise_loop

	exx							;4
	dec c						;4
	jr nz,noise_skip			;7/12
	ld c,b						;4
	add hl,de					;11
	rlc h						;8		utz's noise generator idea
	inc d						;4		improves randomness
	jp noise_next				;10
	
noise_skip

	jr $+2						;12
	jr $+2						;12
	nop							;4
	nop							;4
	
noise_next

	ld a,h						;4
	
noise_volume=$+1
	cp #80						;7
	sbc a,a						;4
	out (#fe),a					;11
	exx							;4

	dec bc						;6
	ld a,b						;4
	or c						;4
	jp nz,noise_loop			;10=106t

	exx

noise_bc=$+1
	ld bc,0
noise_de=$+1
	ld de,0



skip_percussion

	ld (pattern_ptr),sp

sample_ptr=$+1
	ld hl,0

sound_loop0

	ld c,64						;internal loop runs 64 times

sound_loop

sample_read=$
	rlc (hl)					;15 	rotate sample bits in place, rl (hl) or add ix,ix (dummy operation)
	sbc a,a						;4		sbc a,a to make bit into 0 or 255, or xor a to keep it 0

	dec e						;4--+	count bits
	jp z,sample_cycle			;10 |
	jp sample_next				;10

sample_cycle

	ld e,d						;4	|	reload counter
	inc hl						;6--+	advance pointer --24t

sample_next

	exx							;4		squeeker type unrolled code
	ld b,a						;4		sample mask
	xor a						;4
	
	ld sp,sound_list			;10
		
	pop de						;10		ch0_acc
	pop hl						;10		ch0_add
	add hl,de					;11
	rla							;4
	ld (ch0_acc),hl				;16
						
	pop de						;10		ch1_acc
	pop hl						;10		ch1_add
	add hl,de					;11
	rla							;4
	ld (ch1_acc),hl				;16
	
	pop de						;10		ch2_acc
	pop hl						;10		ch2_add
	add hl,de					;11
	rla							;4
	ld (ch2_acc),hl				;16

	pop de						;10		ch3_acc
	pop hl						;10		ch3_add
	add hl,de					;11
	
noise_mode=$
	ds 2,0						;8		rlc h for noise effects

	rla							;4
	ld (ch3_acc),hl				;16

	add a,c						;4		no table like in Squeeker, channels summed as is, for uneven 'volume'
	add a,#ff					;7
	sbc a,#ff					;7
	ld c,a						;4
	sbc a,a						;4

	or b						;4		mix sample
	
	out (#fe),a					;11
		
	exx							;4

	dec c						;4
	jp nz,sound_loop			;10=336t


	dec hl						;last byte of a 64 byte sample packet is #80 means it was the last packet
	ld a,(hl)
	inc hl
	cp #80
	jr nz,sample_no_stop

	ld hl,ADD_IX_IX
	ld (sample_read),hl			;disable sample reading

sample_no_stop

	djnz sound_loop0
	ld (sample_ptr),hl
	
	ld	(.restore_sp + 1),sp
	ld	sp,65000
	push	bc
	push	de
	push	hl
	push	af
	exa	
	exx
	push	af
	push	de
	push	bc
	push	hl
	push	ix
	call	UTILS.wait_any_key
	jp	nz,play_music.end
	pop	ix
	pop	hl
	pop	bc
	pop	de
	pop	af
	exa
	exx
	pop	af
	pop	hl
	pop	de
	pop	bc
.restore_sp:
	ld	sp,0

	jp play_loop
	



		
;variables in the sound_list can't be reordered because of stack-based fetching

sound_list

ch0_add		dw 0
ch0_acc		dw 0
ch1_add		dw 0
ch1_acc		dw 0
ch2_add		dw 0
ch2_acc		dw 0
ch3_add		dw 0
ch3_acc		dw 0


;compiled music data

	align 2

music_data:
	dw .pattern
	dw .loop
;sample data

.sample_list:
	dw .sample_1
	dw .sample_2
	dw .sample_3
	dw .sample_4
	dw .sample_5
	dw .sample_6
	dw .sample_7
	align 256

	align 64/8

.sample_1:
	db 15,195,255,0,0,28,1,255
	db 255,160,0,0,0,0,0,5
	db 255,255,255,240,0,0,0,0
	db 1,255,255,255,240,0,0,0
	db 0,0,0,0,0,0,3,255
	db 255,224,0,195,255,248,0,0
	db 0,127,255,248,0,0,0,0
	db 0,15,255,255,255,254,0,0
	db 0,0,0,0,63,255,255,255
	db 224,0,0,0,0,0,7,255
	db 255,255,255,255,255,255,0,0
	db 0,0,0,0,0,0,0,128
.sample_2:
	db 59,96,32,0,223,159,128,0
	db 0,0,255,255,192,0,0,127
	db 248,0,4,30,240,13,3,255
	db 192,0,7,252,16,1,3,255
	db 192,0,0,255,112,11,119,176
	db 0,0,23,255,148,12,16,64
	db 19,125,11,87,0,0,0,143
	db 255,176,7,240,1,0,67,123
	db 120,0,48,192,105,194,63,129
	db 246,128,0,5,106,190,232,192
	db 0,6,184,79,200,6,144,0
	db 81,224,0,1,47,224,0,128
.sample_3:
	db 0,1,0,0,64,0,20,0
	db 1,0,136,0,0,0,0,0
	db 0,69,0,0,4,0,19,42
	db 0,0,0,0,0,0,0,128
.sample_4:
.sample_5:
.sample_6:
.sample_7:


.pattern:
	dw #c3f,#103,#206,#0,#0,NOP_2
	dw #c01,#0
	dw #c01,#103
	dw #c01,#0
	dw #c61,#103
	dw #c01,#0
	dw #c01,#103
	dw #c01,#0
	dw #c41,#103
	dw #c01,#0
	dw #c01,#103
	dw #c01,#0
	dw #c61,#103
	dw #c01,#0
	dw #c01,#103
	dw #c01,#0
	dw #c21,#103
	dw #c01,#0
	dw #c01,#103
	dw #c01,#0
	dw #c61,#103
	dw #c01,#0
	dw #c01,#103
	dw #c01,#0
	dw #c41,#103
	dw #c01,#0
	dw #c01,#103
	dw #c01,#0
	dw #c61,#103
	dw #c01,#0
	dw #c01,#103
	dw #c01,#0
	dw #c23,#134,#268
	dw #c01,#0
	dw #c01,#134
	dw #c01,#0
	dw #c61,#134
	dw #c01,#0
	dw #c01,#134
	dw #c01,#0
	dw #c41,#134
	dw #c01,#0
	dw #c01,#134
	dw #c01,#0
	dw #c61,#134
	dw #c01,#0
	dw #c01,#134
	dw #c01,#0
	dw #c23,#e6,#1cd
	dw #c01,#0
	dw #c01,#e6
	dw #c01,#0
	dw #c61,#e6
	dw #c01,#0
	dw #c01,#e6
	dw #c01,#0
	dw #c41,#e6
	dw #c01,#0
	dw #c01,#e6
	dw #c01,#0
	dw #c61,#e6
	dw #c01,#0
	dw #c01,#e6
	dw #c01,#0
	dw #c2f,#103,#206,#0,#0
	dw #c01,#0
	dw #c01,#103
	dw #c01,#0
	dw #c61,#103
	dw #c01,#0
	dw #c01,#103
	dw #c01,#0
	dw #c41,#103
	dw #c01,#0
	dw #c01,#103
	dw #c01,#0
	dw #c61,#103
	dw #c01,#0
	dw #c01,#103
	dw #c01,#0
	dw #c21,#103
	dw #c01,#0
	dw #c01,#103
	dw #c01,#0
	dw #c61,#103
	dw #c01,#0
	dw #c01,#103
	dw #c01,#0
	dw #c41,#103
	dw #c01,#0
	dw #c01,#103
	dw #c01,#0
	dw #c61,#103
	dw #c01,#0
	dw #c01,#103
	dw #c01,#0
	dw #c23,#134,#268
	dw #c01,#0
	dw #c01,#134
	dw #c01,#0
	dw #c61,#134
	dw #c01,#0
	dw #c01,#134
	dw #c01,#0
	dw #c41,#134
	dw #c01,#0
	dw #c01,#134
	dw #c01,#0
	dw #c61,#134
	dw #c01,#0
	dw #c01,#134
	dw #c01,#0
	dw #c23,#e6,#1cd
	dw #c01,#0
	dw #c01,#e6
	dw #c01,#0
	dw #c61,#e6
	dw #c01,#0
	dw #c41,#e6
	dw #c01,#0
	dw #c45,#e6,#353
	dw #c45,#0,#35b
	dw #c45,#e6,#363
	dw #c0d,#0,#36b,#353
	dw #c4d,#e6,#373,#35b
	dw #c0d,#0,#37b,#363
	dw #c4d,#e6,#383,#36b
	dw #c0d,#0,#38b,#373
.loop:
	dw #c2f,#103,#206,#4d1,#4c1
	dw #c01,#0
	dw #c01,#103
	dw #c01,#0
	dw #c61,#103
	dw #c01,#0
	dw #c09,#103,#4c1
	dw #c01,#0
	dw #c45,#103,#66e
	dw #c01,#0
	dw #c05,#103,#611
	dw #c01,#0
	dw #c65,#103,#568
	dw #c01,#0
	dw #c0d,#103,#4d1,#65e
	dw #c01,#0
	dw #c2d,#103,#4d1,#601
	dw #c01,#0
	dw #c0d,#103,#568,#558
	dw #c01,#0
	dw #c6d,#103,#611,#4c1
	dw #c01,#0
	dw #c09,#103,#4c1
	dw #c01,#0
	dw #c49,#103,#558
	dw #c01,#0
	dw #c09,#103,#601
	dw #c01,#0
	dw #c65,#103,#5c9
	dw #c05,#0,#5e1
	dw #c05,#103,#5f1
	dw #c05,#0,#5f9
	dw #c27,#134,#268,#611
	dw #c01,#0
	dw #c09,#134,#5c9
	dw #c09,#0,#5e1
	dw #c69,#134,#5f1
	dw #c09,#0,#5f9
	dw #c09,#134,#601
	dw #c01,#0
	dw #c41,#134
	dw #c01,#0
	dw #c01,#134
	dw #c01,#0
	dw #c61,#134
	dw #c01,#0
	dw #c01,#134
	dw #c01,#0
	dw #c27,#e6,#1cd,#39b
	dw #c01,#0
	dw #c01,#e6
	dw #c01,#0
	dw #c61,#e6
	dw #c01,#0
	dw #c09,#e6,#38b
	dw #c01,#0
	dw #c41,#e6
	dw #c01,#0
	dw #c01,#e6
	dw #c01,#0
	dw #c61,#e6
	dw #c01,#0
	dw #c01,#e6
	dw #c01,#0
	dw #c27,#103,#206,#0
	dw #c01,#0
	dw #c01,#103
	dw #c01,#0
	dw #c61,#103
	dw #c01,#0
	dw #c09,#103,#0
	dw #c01,#0
	dw #c41,#103
	dw #c01,#0
	dw #c01,#103
	dw #c01,#0
	dw #c61,#103
	dw #c01,#0
	dw #c01,#103
	dw #c01,#0
	dw #c21,#103
	dw #c01,#0
	dw #c05,#103,#95a
	dw #c05,#0,#972
	dw #c65,#103,#982
	dw #c05,#0,#98a
	dw #c05,#103,#992
	dw #c05,#0,#a90
	dw #c4d,#103,#aa0,#95a
	dw #c0d,#0,#aa8,#972
	dw #c0d,#103,#ab0,#982
	dw #c0d,#0,#ab8,#98a
	dw #c6d,#103,#bdb,#992
	dw #c0d,#0,#beb,#a90
	dw #c0d,#103,#bf3,#aa0
	dw #c0d,#0,#c13,#aa8
	dw #c2f,#134,#268,#c23,#ab0
	dw #c09,#0,#ab8
	dw #c09,#134,#bdb
	dw #c09,#0,#beb
	dw #c69,#134,#bf3
	dw #c09,#0,#c13
	dw #c09,#134,#c13
	dw #c01,#0
	dw #c45,#134,#819
	dw #c01,#0
	dw #c05,#134,#568
	dw #c05,#0,#0
	dw #c65,#134,#66e
	dw #c05,#0,#0
	dw #c0d,#134,#819,#809
	dw #c05,#0,#0
	dw #c2f,#e6,#1cd,#737,#558
	dw #c09,#0,#0
	dw #c09,#e6,#65e
	dw #c09,#0,#0
	dw #c69,#e6,#809
	dw #c09,#0,#0
	dw #c09,#e6,#727
	dw #c01,#0
	dw #c41,#e6
	dw #c01,#0
	dw #c01,#e6
	dw #c01,#0
	dw #c61,#e6
	dw #c01,#0
	dw #c01,#e6
	dw #c01,#0
	dw #c27,#103,#206,#4d1
	dw #c01,#0
	dw #c01,#103
	dw #c01,#0
	dw #c61,#103
	dw #c01,#0
	dw #c09,#103,#4c1
	dw #c01,#0
	dw #c45,#103,#66e
	dw #c01,#0
	dw #c05,#103,#611
	dw #c01,#0
	dw #c65,#103,#568
	dw #c01,#0
	dw #c0d,#103,#4d1,#65e
	dw #c01,#0
	dw #c2d,#103,#4d1,#601
	dw #c01,#0
	dw #c0d,#103,#568,#558
	dw #c01,#0
	dw #c6d,#103,#611,#4c1
	dw #c01,#0
	dw #c09,#103,#4c1
	dw #c01,#0
	dw #c49,#103,#558
	dw #c01,#0
	dw #c09,#103,#601
	dw #c01,#0
	dw #c65,#103,#5c9
	dw #c05,#0,#5e1
	dw #c05,#103,#5f1
	dw #c05,#0,#5f9
	dw #c27,#134,#268,#611
	dw #c01,#0
	dw #c09,#134,#5c9
	dw #c09,#0,#5e1
	dw #c69,#134,#5f1
	dw #c09,#0,#5f9
	dw #c09,#134,#601
	dw #c01,#0
	dw #c41,#134
	dw #c01,#0
	dw #c01,#134
	dw #c01,#0
	dw #c61,#134
	dw #c01,#0
	dw #c01,#134
	dw #c01,#0
	dw #c27,#e6,#1cd,#39b
	dw #c01,#0
	dw #c01,#e6
	dw #c01,#0
	dw #c61,#e6
	dw #c01,#0
	dw #c09,#e6,#38b
	dw #c01,#0
	dw #c41,#e6
	dw #c01,#0
	dw #c01,#e6
	dw #c01,#0
	dw #c61,#e6
	dw #c01,#0
	dw #c01,#e6
	dw #c01,#0
	dw #c27,#103,#206,#0
	dw #c01,#0
	dw #c01,#103
	dw #c01,#0
	dw #c61,#103
	dw #c01,#0
	dw #c09,#103,#0
	dw #c01,#0
	dw #c41,#103
	dw #c01,#0
	dw #c01,#103
	dw #c01,#0
	dw #c61,#103
	dw #c01,#0
	dw #c01,#103
	dw #c01,#0
	dw #c21,#103
	dw #c01,#0
	dw #c05,#103,#489
	dw #c05,#0,#4a1
	dw #c65,#103,#4b1
	dw #c05,#0,#4b9
	dw #c05,#103,#4c1
	dw #c05,#0,#491
	dw #c4d,#103,#4a1,#489
	dw #c0d,#0,#4a9,#4a1
	dw #c0d,#103,#4b1,#4b1
	dw #c0d,#0,#4b9,#4b9
	dw #c6d,#103,#489,#4c1
	dw #c0d,#0,#499,#491
	dw #c0d,#103,#4a1,#4a1
	dw #c0d,#0,#4c1,#4a9
	dw #c2f,#134,#268,#4d1,#4b1
	dw #c09,#0,#4b9
	dw #c09,#134,#489
	dw #c09,#0,#499
	dw #c69,#134,#4a1
	dw #c09,#0,#4c1
	dw #c09,#134,#4c1
	dw #c01,#0
	dw #c45,#134,#66e
	dw #c01,#0
	dw #c05,#134,#611
	dw #c05,#0,#0
	dw #c65,#134,#568
	dw #c05,#0,#0
	dw #c0d,#134,#4d1,#65e
	dw #c05,#0,#0
	dw #c2f,#e6,#1cd,#39b,#601
	dw #c09,#0,#0
	dw #c69,#e6,#558
	dw #c09,#0,#0
	dw #c6d,#e6,#611,#4c1
	dw #c09,#0,#0
	dw #c6d,#e6,#568,#38b
	dw #c01,#0
	dw #c65,#e6,#4d1
	dw #c01,#0
	dw #c6d,#e6,#40c,#601
	dw #c21,#0
	dw #c2d,#e6,#39b,#558
	dw #c01,#0
	dw #c2d,#e6,#337,#4c1
	dw #c01,#0
	dw 0

	endmodule