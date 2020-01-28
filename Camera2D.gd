extends Camera2D

export var decay_rate = 0.4
export var max_angle = 0.1
export var max_offset = 50

var _start_position
var _start_rotation
var _trauma

func move(dir):
	if _trauma <= 0.0:
		position.x = lerp(position.x, dir * 50, 0.02)
	
func add_trauma(amount):
	_trauma = min(_trauma + amount, 1)

func _ready():
	_start_position = position
	_start_rotation = rotation
	_trauma = 0.0

func _process(delta):
	if _trauma > 0:
#		print(_trauma)
		_decay_trauma(delta)
		_apply_shake()
		
func _decay_trauma(delta):
	var change = decay_rate * delta
	_trauma = max(_trauma - change, 0)

func _apply_shake():
	var shake = _trauma * _trauma
	var angle = max_angle * shake * _get_neg_or_pos_scalar()
	var o_x = max_offset * shake * _get_neg_or_pos_scalar()
	var o_y = max_offset * shake * _get_neg_or_pos_scalar()
	offset = _start_position + Vector2(o_x, o_y)
	rotation = _start_rotation + angle

func _get_neg_or_pos_scalar():
	return rand_range(-1.0, 1.0)
