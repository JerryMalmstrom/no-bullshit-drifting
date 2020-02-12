extends Control

onready var lb_sc = preload("res://TrackButton.tscn")


func _ready():
	globals.get_webrequest(self, "tracks", "_track_request_completed")
	
	if !globals.logged_in:
		pass
	else:
		logged_in()
	$Control/VBoxContainer/Login_Create/User.grab_focus()


func _track_request_completed(_result, _response_code, _headers, body):
	var response = parse_json(body.get_string_from_utf8()).records

	for x in range( response.size() ):
		
		var thumbname = "res://maps/" + response[x].file.trim_suffix(".tmx") + "_thumb.png"
		var thumb
		if (File.new().file_exists(thumbname)):
			thumb = load(thumbname)
		else:
			thumb = load("res://maps/default_thumb.png")
		
		$Control/VBoxContainer/ItemList.add_item(response[x].name, thumb)
		$Control/VBoxContainer/ItemList.set_item_metadata(x, response[x].id)
		$Control/VBoxContainer/ItemList.set_item_tooltip(x, response[x].file)
		
#		if (File.new().file_exists(thumbname)):
#			lb.icon = load(thumbname)
#		else:
#			lb.icon = load("res://maps/default_thumb.png")
#		$TrackSelect/HBoxContainer/ScrollContainer/Tracklist.add_child(lb)
#		lb.connect("mouse_entered", self, "_fill_text", [response[x].name])
#		lb.connect("button_down", self, "_load_map", [response[x].id])

#	$TrackSelect.show()
#	$TrackSelect/HBoxContainer/ScrollContainer/Tracklist.get_child(0).grab_focus()


func _unhandled_input(event):
	if event.is_pressed() and event.is_action("ui_cancel"):
		$Options.hide()

func _load_map(track):
	globals.current_track = track
	var _res = get_tree().change_scene("res://World.tscn")
	
func _on_btn_save_pressed():
	globals.show_ghost = $Options/VBoxContainer2/btn_ghost.pressed
	globals.show_best_lap = $Options/VBoxContainer2/btn_trail.pressed
	globals.show_current_lap = $Options/VBoxContainer2/btn_trail2.pressed
	$Options.hide()
	$Control/VBoxContainer/btn_options.grab_focus()
#
#func _on_btn_selectmap_pressed():
#	globals.get_webrequest(self, "tracks", "_track_request_completed")
#
#func _track_request_completed(_result, _response_code, _headers, body):
#	var response = parse_json(body.get_string_from_utf8()).records
#
#	for item in $TrackSelect/HBoxContainer/ScrollContainer/Tracklist.get_children():
#		$TrackSelect/HBoxContainer/ScrollContainer/Tracklist.remove_child(item)
#
#	for x in range( response.size() ):
#		var lb = lb_sc.instance()
#		lb.text = response[x].name
#		var thumbname = "res://maps/" + response[x].file.trim_suffix(".tmx") + "_thumb.png"
#
#		if (File.new().file_exists(thumbname)):
#			lb.icon = load(thumbname)
#		else:
#			lb.icon = load("res://maps/default_thumb.png")
#		$TrackSelect/HBoxContainer/ScrollContainer/Tracklist.add_child(lb)
##		lb.connect("mouse_entered", self, "_fill_text", [response[x].name])
#		lb.connect("button_down", self, "_load_map", [response[x].id])
#
#	$TrackSelect.show()
#	$TrackSelect/HBoxContainer/ScrollContainer/Tracklist.get_child(0).grab_focus()
	
func _on_btn_options_pressed():
	$Options.show()
	$Options/VBoxContainer2/btn_ghost.grab_focus()

func _on_btn_quit_pressed():
	get_tree().quit()

func logged_in():
	$Control/VBoxContainer/Login_Create/User.text = globals.user
	$Control/VBoxContainer/Login_Create/User.editable = false
	$Control/VBoxContainer/Login_Create/Button_Login.hide()
	$Control/VBoxContainer/Login_Create/Password.hide()
	$Control/VBoxContainer/ItemList.grab_focus()


func _on_Button_Login_pressed():
	var response = yield(globals.get_user($Control/VBoxContainer/Login_Create/User.text.to_lower(), $Control/VBoxContainer/Login_Create/Password.text), "completed")
	if !response:
		var pop = ConfirmationDialog.new()
		pop.dialog_text = "User does not exist / wrong password"
		add_child(pop)
		pop.popup_centered()
	else:
		globals.logged_in = true
		globals.user = $Control/VBoxContainer/Login_Create/User.text.to_lower()
		logged_in()
		
		


func _on_Load_Map_pressed():
	_load_map($Control/VBoxContainer/ItemList.get_item_metadata($Control/VBoxContainer/ItemList.get_selected_items()[0]))


func _on_Password_text_entered(new_text):
	_on_Button_Login_pressed()
