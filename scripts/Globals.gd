extends Node

var started = false
var current_laptime = 0.0
var best_laptime = 9999.0
var last_laptime = 0.0

var speed = 0.0
const MAX_SPEED = 1200.0

var current_lap_ghost = PoolVector3Array()
var best_lap_ghost = PoolVector3Array()
var current_lap_ghost_array = []
var best_lap_ghost_array = []

var show_current_lap = false
var show_best_lap = false
var show_ghost = false

var current_track = 1

var user_data = {}

var options = {}

# var logged_in = false

var car_texture = "res://assets/cars/car_black_small_5.png"

onready var sc = load("res://scripts/httpreq.gd")

func _ready():
	randomize()
	user_data.name = "Player_" + "%.0f" % rand_range(100, 99999)
	user_data.logged_in = false
	
	options.fog = true
	

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
	current_lap_ghost_array.clear()

func reset_best_ghost():
	best_lap_ghost_array.clear()

func get_webrequest(caller, function, callback):
	var http_request = HTTPRequest.new()
	http_request.set_script(sc)
	add_child(http_request)
	http_request.connect("request_completed", caller, callback)
	
	var error = http_request.request("https://gg.jmns.se/api.php/records/" + function)
	if error != OK:
		push_error("An error occurred in the HTTP request.")
		
	http_request.connect("request_completed", http_request, "destroy")
	
func set_webrequest(caller, function, callback, data):
	var http_request = HTTPRequest.new()
	http_request.set_script(sc)
	add_child(http_request)
	http_request.connect("request_completed", caller, callback)
	
	var error = http_request.request("https://gg.jmns.se/api.php/records/" + function, ["Content-Type: application/json"], false, HTTPClient.METHOD_POST, data)
	if error != OK:
		push_error("An error occurred in the HTTP request.")

	http_request.connect("request_completed", http_request, "destroy")

func get_user(name, password):
	var http_request = HTTPRequest.new()
	http_request.set_script(sc)
	add_child(http_request)
	
	var data = "user=" + str(name) + "&pass=" + str(password)
	
	var error = http_request.request("https://gg.jmns.se/sp.php/login", ["Content-Type: application/x-www-form-urlencoded"], false, HTTPClient.METHOD_POST, data)
	if error != OK:
		push_error("An error occurred in the HTTP request.")
		
	var u = yield(http_request, "request_completed")
	http_request.queue_free()
	
	var temp = parse_json(u[3].get_string_from_utf8())
	return temp[0][0].result
	
	
	
func create_user(name, password):
	var http_request = HTTPRequest.new()
	http_request.set_script(sc)
	add_child(http_request)
	
	var data = "user=" + str(name) + "&pass=" + str(password)
	
	var error = http_request.request("https://gg.jmns.se/sp.php/usercreate", ["Content-Type: application/x-www-form-urlencoded"], false, HTTPClient.METHOD_POST, data)
	if error != OK:
		push_error("An error occurred in the HTTP request.")
		
	var u = yield(http_request, "request_completed")
	http_request.queue_free()
	
	var temp = parse_json(u[3].get_string_from_utf8())
	return temp[0][0].result
	
func update_user():
	pass
