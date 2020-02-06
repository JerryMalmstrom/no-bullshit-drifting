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

var map_info
var userdata

var best_times = []

#var http_request_track
#var http_request_laptimes

onready var sc = load("res://httpreq.gd")

onready var popup_sc = preload("res://PopoutText.tscn")

func _ready():
	$UI/Loader.visible = true
	
	reset_variables()
	read_userdata()
	get_trackdata(globals.current_track)
	get_laptimes(globals.current_track)

	
func get_trackdata(num):
	var http_request_track = HTTPRequest.new()
	http_request_track.set_script(sc)
	add_child(http_request_track)
	http_request_track.connect("request_completed", self, "_track_request_completed")
	
	var error = http_request_track.request("http://gg.jmns.se/api.php/records/tracks/%s" % num)
	if error != OK:
		push_error("An error occurred in the HTTP request.")
		
	http_request_track.connect("request_completed", http_request_track, "destroy")



func set_laptime(time):
	var json = to_json([{ "track_id": globals.current_track, "name": globals.user, "laptime": time, "setAt": get_current_date(true)}])
	var http_set_laptime = HTTPRequest.new()
	http_set_laptime.set_script(sc)
	add_child(http_set_laptime)
	http_set_laptime.connect("request_completed", self, "_laptime_set_completed")
	http_set_laptime.connect("request_completed", http_set_laptime, "destroy")
	
	var error = http_set_laptime.request("http://gg.jmns.se/api.php/records/best_times", ["Content-Type: application/json"], false, HTTPClient.METHOD_POST, json)
	if error != OK:
		push_error("An error occurred in the HTTP request.")
		
	

func get_laptimes(track):
	var http_request_laptimes = HTTPRequest.new()
	http_request_laptimes.set_script(sc)
	add_child(http_request_laptimes)
	http_request_laptimes.connect("request_completed", self, "_laptimes_request_completed")
	
	var error = http_request_laptimes.request("http://gg.jmns.se/api.php/records/best_times?filter=track_id,eq,%s&order=laptime" % track)
	if error != OK:
		push_error("An error occurred in the HTTP request.")
		
	http_request_laptimes.connect("request_completed", http_request_laptimes, "destroy")


func _track_request_completed(_result, _response_code, _headers, body):
	var response = parse_json(body.get_string_from_utf8())
	read_trackdata(response)
	$Tween.interpolate_property($UI/Loader, "modulate", Color(1,1,1,1), Color(1,1,1,0), .5, Tween.TRANS_LINEAR, Tween.EASE_IN)
	$Tween.start()
	
func _laptime_set_completed(_result, _response_code, _headers, body):
	get_laptimes(globals.current_track)
	
func _laptimes_request_completed(_result, _response_code, _headers, body):
	var response = parse_json(body.get_string_from_utf8()).records
	
	$UI/Control/ColorRect3/lbl_best_names.text = ""
	$UI/Control/ColorRect3/lbl_best_times.text = ""
	
	for x in range( min(10,response.size()) ):
		$UI/Control/ColorRect3/lbl_best_names.text += str(x+1) + ". " + response[x].name + "\n"
		$UI/Control/ColorRect3/lbl_best_times.text += str(response[x].laptime) + "\n"
		globals.best_laptime = float(response[x].laptime)

	
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
	if file.file_exists("user://userdata.json"):
		file.open("user://userdata.json", file.READ)
		userdata = JSON.parse(file.get_as_text()).result
		file.close()
	else:
		var template_file = File.new()
		template_file.open("res://userdata.json", file.READ)
		userdata = JSON.parse(template_file.get_as_text()).result
		template_file.close()
		userdata.username = globals.user
		write_userdata()
	
func write_userdata():
	var file = File.new()
	file.open("user://userdata.json", file.WRITE)
	userdata["last_save"] = "TODO"
	file.store_line(JSON.print(userdata))
	file.close()


func read_trackdata(track):
	map_info = parse_json(track.parameters)
	
	add_child(load("res://maps/" + track.file).instance())
	$car.global_position = Vector2(map_info.car_pos_x, map_info.car_pos_y)
	$car.global_rotation = map_info.car_rot
	$GoalLine.global_position = Vector2(map_info.goal_pos_x, map_info.goal_pos_y)
	$Checkpoint.global_position = Vector2(map_info.check_pos_x, map_info.check_pos_y)
	
	$GoalLine/CollisionShape2D.shape.extents = Vector2(map_info.goal_width, map_info.goal_height)
	$Checkpoint/CollisionShape2D.shape.extents = Vector2(map_info.check_width, map_info.check_height)
	
	$car/Camera2D.limit_right = int(track.width)
	$car/Camera2D.limit_bottom = int(track.height)
	
	

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
	
func popup_text(text, duration = 2):
	var pop = popup_sc.instance()
	pop.text = text
	pop.duration = duration
	$UI.add_child(pop)

func get_current_date(sql = false):
	var dt = OS.get_datetime()
	if sql:
		return "%4d-%02d-%02dT%02d:%02d:%02d" % [dt.year, dt.month, dt.day, dt.hour, dt.minute, dt.second]
	else:
		return "%4d-%02d-%02d %02d:%02d:%02d" % [dt.year, dt.month, dt.day, dt.hour, dt.minute, dt.second]

func _unhandled_input(event):
	if event.is_action_pressed("ui_cancel"):
		var _res = get_tree().change_scene("res://MainMenu.tscn")

func _on_Checkpoint_body_entered(_body):
	checkpoint_hit = true


func _on_GoalLine_body_entered(_body):
	if !globals.started:
		globals.started = true
		popup_text("Go go go!", 0.1)
	else:
		if checkpoint_hit:
			checkpoint_hit = false
			globals.last_laptime = globals.current_laptime
			nbr_lastlap.text = "%.3f" % globals.last_laptime
			globals.current_laptime = 0.0
			current_ghost_point = 0
			if globals.last_laptime < globals.best_laptime:
				popup_text("Great lap!\n%.2f" % globals.last_laptime, 3)
				set_laptime(globals.last_laptime)
#				userdata["trackdata"][map_info.name]["best_lap"] = globals.last_laptime
#				userdata["last_save"] = get_current_date()
#				write_userdata()
				globals.update_ghost()
#				globals.best_laptime = globals.last_laptime
#				nbr_bestlap.text = "%.3f" % globals.best_laptime
			else:
				popup_text("%.2f" % globals.last_laptime, 3)
			globals.reset_ghost()
			$UI/Control/ColorRect3.modulate = Color(1,1,1,1)
			$Tween.interpolate_property($UI/Control/ColorRect3, "modulate", Color(1,1,1,1), Color(1,1,1,.5), 2, Tween.TRANS_LINEAR, Tween.EASE_IN, 5)
			$Tween.start()
		else:
			popup_text("Checkpoint missed!", 2)
			
