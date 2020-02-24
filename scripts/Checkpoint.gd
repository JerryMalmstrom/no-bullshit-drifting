extends Area2D

var triggered = false

func _on_Checkpoint_body_entered(body):
	triggered = true
