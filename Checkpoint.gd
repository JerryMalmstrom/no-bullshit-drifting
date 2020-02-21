extends Area2D

var triggered = false

func _on_Checkpoint_body_entered(_body):
	triggered = true
