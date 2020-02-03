extends Control


var text = ""
var duration = 2.0
var text_in = 0.4
var text_out = 0.6

onready var zoom = $CenterContainer/Control

func _ready():
	$CenterContainer/Control/Label.text	= text
	
	$Tween.interpolate_property(zoom, "rect_scale", Vector2(0,0), Vector2(1,1), text_in, Tween.TRANS_LINEAR, Tween.EASE_IN )
	$Tween.interpolate_property(zoom, "modulate", Color(1,1,1,0), Color(1,1,1,1), text_in, Tween.TRANS_LINEAR, Tween.EASE_IN )
	
	$Tween.interpolate_property(zoom, "rect_scale", Vector2(1,1), Vector2(10,10), text_out, Tween.TRANS_LINEAR, Tween.EASE_OUT, duration + text_in)
	$Tween.interpolate_property(zoom, "modulate", Color(1,1,1,1), Color(1,1,1,0), text_out, Tween.TRANS_LINEAR, Tween.EASE_OUT, duration + text_in)
	
	$Tween.start()


func _on_Tween_tween_all_completed():
	call_deferred("queue_free")
