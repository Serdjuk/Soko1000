	module	TEXT
; progress_file_name:			db 	"progress.C",$80
; 					dw	#00FF
text_crates_label:			db	"Crates",0
text_world_label:			db	"World",0
text_level_label:			db	"Level",0

text_swap_label:			db	"'SPACE' - SWAP",0
text_start_label:			db	"'ENTER' - START",0

text_level_authors:			db	"Level Creators",0
text_year:				db	"2025",0

text_level_menu:			db	"I-Info",0

text_space:				db	"SPACE",0
text_bom:				db	"Back Move",0
text_quit:				db	"Exit",0
text_restart:				db	"Restart",0
text_color:				db	"Color",0
text_smooth_motion:			db	"Smooth Move",0
text_confirm_exit:			db	"Exit to main menu ?", 0
text_confirm_restart:			db	"Restart level ?", 0
text_yes:				db	"Yes", 0
text_no:				db	"No", 0

text_start_game:			db	"Start Game",0
text_keyboard:				db	"Keyboard QAOP",0
text_keyboard_clone:			db	"Keyboard QAOP",0
text_save_progress:			db	"Save Progress", 0
text_load_progress:			db	"Load Progress", 0
text_keyboard_wasd:			db	"WASD",0
text_joystick:				db	"Joystick     ",0

text_successfully_saved:		db	"Progress  Saved Successfully", 0
text_successfully_loaded:		db	"Progress Loaded Successfully", 0
text_load_error:			db	"The game crashed, incorrect data", 0

	endmodule