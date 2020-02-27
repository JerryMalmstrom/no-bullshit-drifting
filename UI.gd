extends CanvasLayer


func _unhandled_key_input(event):
	if event.is_action_pressed("ui_cancel"):
		$PopupPanel.popup()


func _on_Sound_slider_value_changed(value):
	AudioServer.set_bus_volume_db(1, linear2db(value))

func _on_Master_slider_value_changed(value):
	AudioServer.set_bus_volume_db(0, linear2db(value))

func _on_Music_slider_value_changed(value):
	AudioServer.set_bus_volume_db(2, linear2db(value))

func _on_fog_cb_toggled(button_pressed):
	get_parent().get_node("Fog").visible = button_pressed


func _on_ghost_cb_toggled(button_pressed):
	globals.show_ghost = button_pressed


func _on_line_cb_toggled(button_pressed):
	globals.show_best_lap = button_pressed
