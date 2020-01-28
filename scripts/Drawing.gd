extends Node2D

const TRACK_LENGTH = 400

#var track_size = PoolIntArray()
#var track_right = PoolVector2Array()
#var track_left = PoolVector2Array()

var track = []

onready var car = get_parent().get_node("car")
onready var left_back_wheel = car.get_node("Pivot/rubber_left")
onready var right_back_wheel = car.get_node("Pivot/rubber_right")

func _process(_delta):
	#if( track_size.size() >= TRACK_LENGTH ):
	#	track_size.remove(0)
	#	track_right.remove(0)
	#	track_left.remove(0)

	if (track.size() >= TRACK_LENGTH):
		track.remove(0)

	track.append({"right": right_back_wheel.global_position, "left": left_back_wheel.global_position, "size": car.skid_size_back)

	#track_right.append(right_back_wheel.global_position)
	#track_left.append(left_back_wheel.global_position)
	#track_size.append(car.skid_size_back)
	
	update()
	
func _draw():
	
	if globals.show_current_lap:
		for y in range(globals.current_lap_ghost_array.size() -1 ):
			draw_line(globals.current_lap_ghost_array[y].pos, globals.current_lap_ghost_array[y+1].pos, Color(0, 0, 0, 0.2), 10)
	
	if globals.show_best_lap:
		for x in range(globals.best_lap_ghost_array.size() -1 ):
			draw_line(globals.best_lap_ghost_array[x].pos, globals.best_lap_ghost_array[x+1].pos, Color(1, 0, 0, 0.2), 10)
	
	#for i in range(track_size.size() -1 ):
	#	if track_size[i] > 0:
	#		draw_line(track_right[i], track_right[i+1], Color(0, 0, 0, 0.7), track_size[i])
	#		draw_line(track_left[i], track_left[i+1], Color(0, 0, 0, 0.7), track_size[i])
	
	for i in range(track.size() -1 ):
		if track[i].size > 0:
			draw_line(track[i].right, track[i+1].right, Color(0, 0, 0, 0.7), track[i].size)
			draw_line(track[i].left, track[i+1].left, Color(0, 0, 0, 0.7), track[i].size)
