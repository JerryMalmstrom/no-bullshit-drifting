extends Node2D

const TRACK_LENGTH = 200

var track01_back   = PoolIntArray()

var track11 = PoolVector2Array()
var track12 = PoolVector2Array()


onready var car1 = get_parent().get_node("car")
onready var left_back_wheel1 = car1.get_node("Pivot/rubber_left")
onready var right_back_wheel1 = car1.get_node("Pivot/rubber_right")

#var TMoffset = Vector2(525,300)
var TMoffset = Vector2(0,0)

func _process(_delta):
	if( track01_back.size() >= TRACK_LENGTH ):
		track01_back.remove(0)
		track11.remove(0)
		track12.remove(0)

	track11.append(right_back_wheel1.global_position - TMoffset)
	track12.append(left_back_wheel1.global_position - TMoffset)
	track01_back.append(car1.skid_size_back)
	update()
	
func _draw():
	
	if globals.show_current_lap:
		for y in range(globals.current_lap_ghost.size() -1 ):
			draw_line(Vector2(globals.current_lap_ghost[y].x,globals.current_lap_ghost[y].y), Vector2(globals.current_lap_ghost[y+1].x,globals.current_lap_ghost[y+1].y), Color(0, 1, 0, 1), 10)
	
	for x in range(globals.best_lap_ghost.size() -1 ):
		draw_line(Vector2(globals.best_lap_ghost[x].x,globals.best_lap_ghost[x].y), Vector2(globals.best_lap_ghost[x+1].x,globals.best_lap_ghost[x+1].y), Color(1, 0, 0, 1), 10)
	
	for i in range(track01_back.size() -1 ):
		if track01_back[i] > 0:
			draw_line(track11[i], track11[i+1], Color(0, 0, 0, 0.7), track01_back[i])
			draw_line(track12[i], track12[i+1], Color(0, 0, 0, 0.7), track01_back[i])
	
