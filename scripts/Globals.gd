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

var show_current_lap = false
var show_best_lap = false
var show_ghost = false

var current_track = 0

var user = "Jerry"

onready var sc = load("res://httpreq.gd")

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
	current_lap_ghost_array.clear()

func reset_best_ghost():
	best_lap_ghost_array.clear()

func get_webrequest(caller, function, callback):
	var http_request = HTTPRequest.new()
	http_request.set_script(sc)
	add_child(http_request)
	http_request.connect("request_completed", caller, callback)
	
	var error = http_request.request("http://gg.jmns.se/api.php/records/" + function)
	if error != OK:
		push_error("An error occurred in the HTTP request.")
		
	http_request.connect("request_completed", http_request, "destroy")
	
func set_webrequest(caller, function, callback, data):
	var http_request = HTTPRequest.new()
	http_request.set_script(sc)
	add_child(http_request)
	http_request.connect("request_completed", caller, callback)
	
	var error = http_request.request("http://gg.jmns.se/api.php/records/" + function, ["Content-Type: application/json"], false, HTTPClient.METHOD_POST, data)
	if error != OK:
		push_error("An error occurred in the HTTP request.")

	http_request.connect("request_completed", http_request, "destroy")
