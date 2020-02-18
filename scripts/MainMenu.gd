extends Control

#onready var c_user = $"Right/control-user"
#onready var c_track = $"Right/control-track"
#onready var c_options = $"Right/control-options"
#onready var itemlist = $"Right/control-track/VBoxContainer/ItemList"
#onready var in_user = $"Right/control-user/VBoxContainer/Login_Create/User"
#onready var in_pass = $"Right/control-user/VBoxContainer/Login_Create/Password"

onready var in_user = get_node("MarginContainer/HBoxContainer/Left/Menu/HBoxContainer/Username")
onready var in_pass = get_node("MarginContainer/HBoxContainer/Left/Menu/HBoxContainer/Password")


var tracks = []
var cars = []
var current_track = 0
var current_car = 0

func _ready():
#	hide_all()
	globals.get_webrequest(self, "tracks", "_track_request_completed")
	
	var dir = Directory.new()
	if dir.open("res://assets/cars") == OK:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if file_name.get_extension() == "png":
				cars.append("res://assets/cars/" + file_name.get_file())
				
			file_name = dir.get_next()
	else:
		print("Not ok")

	
#	if !globals.logged_in:
#		pass
#	else:
#		logged_in()


func _track_request_completed(_result, _response_code, _headers, body):
	var response = parse_json(body.get_string_from_utf8()).records

	for x in range( response.size() ):
		
		var thumbname = "res://maps/" + response[x].file.trim_suffix(".tmx") + "_thumb.png"
		var thumb
		if (File.new().file_exists(thumbname)):
			thumb = load(thumbname)
		else:
			thumb = load("res://maps/default_thumb.png")
		
		tracks.append({"id": response[x].id, "name": response[x].name, "thumb": thumb})
		
#		itemlist.add_item(response[x].name, thumb)
#		itemlist.set_item_metadata(x, response[x].id)
#		itemlist.set_item_tooltip(x, response[x].file)
		
	$MarginContainer/HBoxContainer/Right/TrackSelect/TextureRect.texture = tracks[current_track].thumb
	$MarginContainer/HBoxContainer/Right/Track_label.text = tracks[current_track].name

#func _unhandled_input(event):
#	if event.is_pressed() and event.is_action("ui_cancel"):
#		$Options.hide()

func _load_map(track):
	globals.current_track = track
	globals.car_texture = cars[current_car]
	var _res = get_tree().change_scene("res://World.tscn")
	
#func _on_btn_save_pressed():
#	globals.show_ghost = c_options.get_node("VBoxContainer/chk_ghost").pressed
#	globals.show_best_lap = c_options.get_node("VBoxContainer/chk_best_trail").pressed
#	globals.show_current_lap = c_options.get_node("VBoxContainer/chk_trail").pressed
#	c_options.hide()

func logged_in():
	in_user.text = globals.user
	in_user.editable = false
#	$"Right/control-user/VBoxContainer/Login_Create/Button_Login".hide()
#	$"Right/control-user/VBoxContainer/Login_Create/Button_Reg".hide()
	$MarginContainer/HBoxContainer/Left/Menu/HBoxContainer/Login.hide()
	$MarginContainer/HBoxContainer/Left/Menu/HBoxContainer/Register.hide()
	in_pass.hide()
	

#func _on_Button_Login_pressed():
#	var response = yield(globals.get_user(in_user.text.to_lower(), in_pass.text), "completed")
#	if !response:
#		var pop = ConfirmationDialog.new()
#		pop.dialog_text = "User does not exist / wrong password"
#		add_child(pop)
#		pop.popup_centered()
#	else:
#		globals.logged_in = true
#		globals.user = in_user.text.to_lower()
#		logged_in()
		
		
#
#func _on_Password_text_entered(new_text):
#	_on_Button_Login_pressed()
#
#func _on_ItemList_item_activated(index):
#	_load_map(index+1)



#func hide_all():
#	for item in get_node("Right").get_children():
#		item.hide()

#func _on_USER_pressed():
#	hide_all()
#	c_user.show()
#
#func _on_TRACK_pressed():
#	hide_all()
#	c_track.show()
#
#func _on_OPTIONS_pressed():
#	hide_all()
#	c_options.show()


#func _on_QUIT_pressed():
#	get_tree().quit()

func _on_Track_L_pressed():
	current_track = clamp(current_track-1, 0, tracks.size()-1)
	
	$MarginContainer/HBoxContainer/Right/TrackSelect/TextureRect.texture = tracks[current_track].thumb
	$MarginContainer/HBoxContainer/Right/Track_label.text = tracks[current_track].name
		
func _on_Track_R_pressed():
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
	
	print(response)
	
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
			globals.logged_in = true
			globals.user = in_user.text.to_lower()
			logged_in()


func _on_Password_text_entered(new_text):
	_on_Login_pressed()
