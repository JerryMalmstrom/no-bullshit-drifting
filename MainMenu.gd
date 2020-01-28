extends Control


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func _on_map01_pressed():
	globals.current_track = 0
	get_tree().change_scene("res://World.tscn")
	


func _on_map02_pressed():
	globals.current_track = 1
	get_tree().change_scene("res://World.tscn")
