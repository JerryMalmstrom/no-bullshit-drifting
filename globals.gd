extends Node

var started = false
var current_laptime = 0.0
var best_laptime = 9999.0
var last_laptime = 0.0

var speed = 0.0
const MAX_SPEED = 900.0

var current_lap_ghost = PoolVector3Array()
var best_lap_ghost = PoolVector3Array()

var best_lap_ghost_array = []
var current_lap_ghost_array = []

var show_current_lap = true
var show_best_lap = true

var show_ghost = true

var current_track = 0

func _ready():
	pass

func add_ghost_point(pos : Vector2, rot : float, time : float):
	current_lap_ghost_array.append({ "pos": pos, "rot": rot, "time": time })

func get_ghost_point(index : int, best : bool):
	if best:
		return best_lap_ghost_array[index]
	else:
		return current_lap_ghost_array[index]
	

func update_ghost():
	best_lap_ghost_array = current_lap_ghost_array.duplicate(true)
	
func reset_ghost():
#	current_lap_ghost.resize(0)
	current_lap_ghost_array.clear()

func reset_best_ghost():
	best_lap_ghost_array.clear()
