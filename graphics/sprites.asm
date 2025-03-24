	module	SPRITE

wall_01_left:				incbin "./graphics/wall_01_left.wbm", 4
wall_01_right:				incbin "./graphics/wall_01_right.wbm", 4
container_left:				incbin "./graphics/container_left.wbm", 4
container_right:			incbin "./graphics/container_right.wbm", 4
crate_left:				incbin "./graphics/crate_left.wbm", 4
crate_right:				incbin "./graphics/crate_right.wbm", 4
player_left:				incbin "./graphics/player_left.wbm", 4
player_right:				incbin "./graphics/player_right.wbm", 4

outside_floor_01:			incbin "./graphics/outside_floor.wbm"

	display "wall_01: ",/A, wall_01_left
	endmodule