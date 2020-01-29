extends Control


func _on_map01_pressed():
	globals.current_track = 0
	var _res = get_tree().change_scene("res://World.tscn")
	


func _on_map02_pressed():
	globals.current_track = 1
	var _res = get_tree().change_scene("res://World.tscn")


func _on_btn_save_pressed():
	globals.show_ghost = $Options/VBoxContainer2/btn_ghost.pressed
	globals.show_best_lap = $Options/VBoxContainer2/btn_trail.pressed
	globals.show_current_lap = $Options/VBoxContainer2/btn_trail2.pressed
	$Options.hide()


func _on_btn_selectmap_pressed():
	$TrackSelect.show()


func _on_btn_options_pressed():
	$Options.show()


func _on_btn_quit_pressed():
	get_tree().quit()
