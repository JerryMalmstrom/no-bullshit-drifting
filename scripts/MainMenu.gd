extends Control

onready var in_user = get_node("MarginContainer/HBoxContainer/Left/Menu/HBoxContainer/Username")
onready var in_pass = get_node("MarginContainer/HBoxContainer/Left/Menu/HBoxContainer/Password")

var tracks = []
var cars = [
	"res://assets/cars/car_black_small_1.png",
	"res://assets/cars/car_black_small_2.png",
	"res://assets/cars/car_black_small_3.png",
	"res://assets/cars/car_black_small_4.png",
	"res://assets/cars/car_black_small_5.png",
	"res://assets/cars/car_blue_small_1.png",
	"res://assets/cars/car_blue_small_2.png",
	"res://assets/cars/car_blue_small_3.png",
	"res://assets/cars/car_blue_small_4.png",
	"res://assets/cars/car_blue_small_5.png",
	"res://assets/cars/car_green_small_1.png",
	"res://assets/cars/car_green_small_2.png",
	"res://assets/cars/car_green_small_3.png",
	"res://assets/cars/car_green_small_4.png",
	"res://assets/cars/car_green_small_5.png",
	"res://assets/cars/car_red_small_1.png",
	"res://assets/cars/car_red_small_2.png",
	"res://assets/cars/car_red_small_3.png",
	"res://assets/cars/car_red_small_4.png",
	"res://assets/cars/car_red_small_5.png",
	"res://assets/cars/car_yellow_small_1.png",
	"res://assets/cars/car_yellow_small_2.png",
	"res://assets/cars/car_yellow_small_3.png",
	"res://assets/cars/car_yellow_small_4.png",
	"res://assets/cars/car_yellow_small_5.png"
]
var current_track = 0
var current_car = 0

func _ready():
	globals.get_webrequest(self, "tracks", "_track_request_completed")
	
	if globals.user_data.logged_in:
		logged_in()


func _track_request_completed(_result, _response_code, _headers, body):
	var response = parse_json(body.get_string_from_utf8()).records

	for x in range( response.size() ):
		tracks.append({"id": response[x].id, "name": response[x].name, "thumb": load("res://maps/" + response[x].file + ".thumb.png"), "enabled": response[x].enabled})
		
	$MarginContainer/HBoxContainer/Right/TrackSelect/TextureRect.texture = tracks[current_track].thumb
	$MarginContainer/HBoxContainer/Right/Track_label.text = tracks[current_track].name

func _load_map(track):
	globals.current_track = track
	globals.car_texture = cars[current_car]
	var _res = get_tree().change_scene("res://World.tscn")
	
func logged_in():
	in_user.text = globals.user_data.name
	in_user.editable = false
	$MarginContainer/HBoxContainer/Left/Menu/HBoxContainer/Login.hide()
	$MarginContainer/HBoxContainer/Left/Menu/HBoxContainer/Create.hide()
	in_pass.hide()
	

func _on_Track_L_pressed():
	current_track = clamp(current_track-1, 0, tracks.size()-1)
	
	if !tracks[current_track].enabled:
		current_track = clamp(current_track-1, 0, tracks.size()-1)
	
	$MarginContainer/HBoxContainer/Right/TrackSelect/TextureRect.texture = tracks[current_track].thumb
	$MarginContainer/HBoxContainer/Right/Track_label.text = tracks[current_track].name
		
func _on_Track_R_pressed():
	current_track = clamp(current_track+1, 0, tracks.size()-1)
	
	if !tracks[current_track].enabled:
		current_track = clamp(current_track+1, 0, tracks.size()-1)
	
	$MarginContainer/HBoxContainer/Right/TrackSelect/TextureRect.texture = tracks[current_track].thumb
	$MarginContainer/HBoxContainer/Right/Track_label.text = tracks[current_track].name

func _on_L_pressed():
	current_car = clamp(current_car-1, 0, cars.size()-1)
	$MarginContainer/HBoxContainer/Right/CarSelect/TextureRect.texture = load(cars[current_car])

func _on_Car_R_pressed():
	current_car = clamp(current_car+1, 0, cars.size()-1)
	$MarginContainer/HBoxContainer/Right/CarSelect/TextureRect.texture = load(cars[current_car])

func _on_Quit_pressed():
	get_tree().quit()


func _on_Start_pressed():
	_load_map(current_track+1)


func _on_Login_pressed():
	var response = yield(globals.get_user(in_user.text.to_lower(), in_pass.text), "completed")
	
	match response:
		"NoUser":
			var pop = ConfirmationDialog.new()
			pop.dialog_text = "User does not exist"
			add_child(pop)
			pop.popup_centered()
		"WrongPass":
			var pop = ConfirmationDialog.new()
			pop.dialog_text = "Wrong password for user"
			add_child(pop)
			pop.popup_centered()
		"Ok":
			globals.user_data.logged_in = true
			globals.user_data.name = in_user.text.to_lower()
			logged_in()

func _on_Create_pressed():
	var response = yield(globals.create_user(in_user.text.to_lower(), in_pass.text), "completed")

	match response:
		"UserExists":
			var pop = ConfirmationDialog.new()
			pop.dialog_text = "User already exists"
			add_child(pop)
			pop.popup_centered()
		"Ok":
			globals.user_data.logged_in = true
			globals.user_data.name = in_user.text.to_lower()
			logged_in()

func _on_Password_text_entered(_new_text):
	_on_Login_pressed()


func _on_Options_pressed():
	$PopupPanel.popup()
