extends Control

onready var lb_sc = preload("res://LinkButton.tscn")

func _ready():
	$Control/VBoxContainer/btn_selectmap.grab_focus()

func _unhandled_input(event):
	if event.is_pressed() and event.is_action("ui_cancel"):
		$TrackSelect.hide()
		$Options.hide()
		$Control/VBoxContainer/btn_selectmap.grab_focus()
		

func _load_map(track):
	globals.current_track = track
	var _res = get_tree().change_scene("res://World.tscn")
	
func _on_btn_save_pressed():
	globals.show_ghost = $Options/VBoxContainer2/btn_ghost.pressed
	globals.show_best_lap = $Options/VBoxContainer2/btn_trail.pressed
	globals.show_current_lap = $Options/VBoxContainer2/btn_trail2.pressed
	$Options.hide()
	$Control/VBoxContainer/btn_options.grab_focus()

func _on_btn_selectmap_pressed():
	globals.get_webrequest(self, "tracks", "_track_request_completed")
		
func _track_request_completed(_result, _response_code, _headers, body):
	var response = parse_json(body.get_string_from_utf8()).records
	
	for x in range( response.size() ):
		var lb = lb_sc.instance()
		lb.text = response[x].name
		$TrackSelect/HBoxContainer/ScrollContainer/Tracklist.add_child(lb)
		lb.connect("mouse_entered", self, "_fill_text", [response[x].name])
		lb.connect("button_down", self, "_load_map", [response[x].id])
	
	$TrackSelect.show()
	$TrackSelect/HBoxContainer/ScrollContainer/Tracklist.get_child(0).grab_focus()
	
func _fill_text(object):
	$TrackSelect/HBoxContainer/RichTextLabel.text = object
	
func _on_btn_options_pressed():
	$Options.show()
	$Options/VBoxContainer2/btn_ghost.grab_focus()


func _on_btn_quit_pressed():
	get_tree().quit()
