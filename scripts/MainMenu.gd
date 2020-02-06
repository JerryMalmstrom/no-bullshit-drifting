extends Control

onready var sc = load("res://httpreq.gd")

func _load_map(track):
	globals.current_track = track
	var _res = get_tree().change_scene("res://World.tscn")
	
func _on_btn_save_pressed():
	globals.show_ghost = $Options/VBoxContainer2/btn_ghost.pressed
	globals.show_best_lap = $Options/VBoxContainer2/btn_trail.pressed
	globals.show_current_lap = $Options/VBoxContainer2/btn_trail2.pressed
	$Options.hide()

func _on_btn_selectmap_pressed():
	var http_request_track = HTTPRequest.new()
	http_request_track.set_script(sc)
	add_child(http_request_track)
	http_request_track.connect("request_completed", self, "_track_request_completed")
	
	var error = http_request_track.request("http://gg.jmns.se/api.php/records/tracks")
	if error != OK:
		push_error("An error occurred in the HTTP request.")
		
	http_request_track.connect("request_completed", http_request_track, "destroy")
	
	
func _track_request_completed(_result, _response_code, _headers, body):
	var response = parse_json(body.get_string_from_utf8()).records
	
	for x in range( response.size() ):
		var lb = LinkButton.new()
		lb.text = response[x].name
		$TrackSelect/HBoxContainer/ScrollContainer/Tracklist.add_child(lb)
		lb.connect("mouse_entered", self, "_fill_text", [response[x].name])
		lb.connect("button_down", self, "_load_map", [response[x].id])
	
	$TrackSelect.show()
	
func _fill_text(object):
	$TrackSelect/HBoxContainer/RichTextLabel.text = object
	
func _on_btn_options_pressed():
	$Options.show()


func _on_btn_quit_pressed():
	get_tree().quit()



