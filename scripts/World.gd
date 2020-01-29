extends Node2D

var checkpoint_hit = false

onready var nbr_laptime = get_tree().root.find_node("nbr_laptime", true, false)
onready var nbr_lastlap = get_tree().root.find_node("nbr_lastlap", true, false)
onready var nbr_bestlap = get_tree().root.find_node("nbr_bestlap", true, false)
onready var pb_speed = get_tree().root.find_node("pb_speed", true, false)

var current_ghost_point = 0
var ghost_rot_offset = deg2rad(90)

var ghost_point_time = 0.0
var ghost_point_current_time = 0.0

var tracks = [
	"res://maps/drifters-map01.cfg",
	"res://maps/drifters-map02.cfg",
]

var map_info
var userdata

func _ready():
	reset_variables()
	read_userdata()
	read_trackdata(globals.current_track)
	
func reset_variables():
	globals.started = false
	globals.reset_ghost()
	globals.current_laptime = 0.0
	globals.best_laptime = 99999.0
	globals.last_laptime = 0.0
	globals.reset_best_ghost()
	
	checkpoint_hit = false
	current_ghost_point = 0
	ghost_point_time = 0.0
	ghost_point_current_time = 0.0
	
func get_userdata(user, key):
	return userdata[user][key]

func set_userdata(user, key, value):
	userdata[user][key] = value

func read_userdata():
	var file = File.new()
	file.open("res://userdata.cfg", file.READ)
	userdata = JSON.parse(file.get_as_text()).result
	file.close()
	
func write_userdata():
	var file = File.new()
	file.open("res://userdata.cfg", file.WRITE)
	file.store_line(userdata.to_json())
	file.close()

func read_trackdata(track):
	var file = File.new()
	file.open(tracks[track], file.READ)
	map_info = parse_json(file.get_as_text())
	file.close()

	add_child(load(map_info.file).instance())
	$car.global_position = Vector2(map_info.car_pos_x, map_info.car_pos_y)
	$car.global_rotation = map_info.car_rot
	$GoalLine.global_position = Vector2(map_info.goal_pos_x, map_info.goal_pos_y)
	$Checkpoint.global_position = Vector2(map_info.check_pos_x, map_info.check_pos_y)
	
	$GoalLine/CollisionShape2D.shape.extents = Vector2(map_info.goal_width, map_info.goal_height)
	$Checkpoint/CollisionShape2D.shape.extents = Vector2(map_info.check_width, map_info.check_height)
	
	$car/Camera2D.limit_right = map_info.width
	$car/Camera2D.limit_bottom = map_info.height


func _process(delta):
	if globals.started:
		globals.current_laptime += delta
		nbr_laptime.text = "%.2f" % globals.current_laptime
		
	if globals.best_lap_ghost_array.size() > 0:
		ghost_point_current_time += delta
		
		if ghost_point_current_time >= ghost_point_time:
			if globals.show_ghost:
				$Tween.interpolate_property($ghost,"global_position", $ghost.global_position, globals.get_ghost_point(current_ghost_point, true).pos, globals.get_ghost_point(current_ghost_point, true).time)
				$Tween.interpolate_property($ghost,"rotation", $ghost.rotation, globals.get_ghost_point(current_ghost_point, true).rot + ghost_rot_offset, globals.get_ghost_point(current_ghost_point, true).time)
				$Tween.start()

			ghost_point_time = globals.get_ghost_point(current_ghost_point, true).time
			
			current_ghost_point += 1
			ghost_point_current_time = 0.0
			
		if current_ghost_point >= globals.best_lap_ghost_array.size():
			current_ghost_point = 0
		
	pb_speed.value = (max(globals.speed,0.0001) / globals.MAX_SPEED) * 100
	

func _unhandled_input(event):
	if event.is_action_pressed("ui_cancel"):
		get_tree().change_scene("res://MainMenu.tscn")

func _on_Checkpoint_body_entered(body):
	checkpoint_hit = true


func _on_GoalLine_body_entered(body):
	if !globals.started:
		globals.started = true
	else:
		if checkpoint_hit:
			checkpoint_hit = false
			globals.last_laptime = globals.current_laptime
			nbr_lastlap.text = "%.3f" % globals.last_laptime
			globals.current_laptime = 0.0
			current_ghost_point = 0
			if globals.last_laptime < globals.best_laptime:
				#userdata[globals.user][], "best_lap")
				globals.update_ghost()
				globals.best_laptime = globals.last_laptime
				nbr_bestlap.text = "%.3f" % globals.best_laptime
			globals.reset_ghost()
		else:
			print("Missed checkpoint")
			
