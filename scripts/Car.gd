extends KinematicBody2D

var velocity 	= Vector2( 0.0, 0.0 )
var thrust   	= 0.0
var speed    	= 0.0
var reversing 	= false

export (int) var car_texture_number = 0
export (int) var player = 1

const MAX_ANGULAR_ACCELERATION = 0.04	* 1.5
const ANGULAR_ACCELERATION     = 0.006	* 1.5
const STEERIN_TURNING          = 0.1	* 1.0
const AGILITY_RATIO            = 0.5	* 1.0
const ACCELERATION             = 0.1	* 1.5
const WOBBLE_RATE              = 0.005	* 1.0
const BREAKING                 = 3.0	* 1.5
const MAX_SPEED                = 900
const ANGULAR_DAMPENING 	   = 0.85	* 1.0

var angular_friction = 0.0
var angular_velocity = 0.0
var orientation      = 0.0
var turning          = 0.0
var facing           = Vector2 ( 0.0, 0.0 )
var wheel_facing     = Vector2 ( 0.0, 0.0 )
var drag_vector      = Vector2 ( 0.0, 0.0 )
var drag             = 0.0
var skid_size_front  = 0.0
var skid_size_back   = 0.0

var collision_time = 0.0

const GHOST_SAVE_INTERVAL = 0.1
var ghost_save_time = 0.0

#var drift_size = 0.0

var active = true
var car_texture1 = preload("res://assets/car_black_small_5.png")


func _ready():
	velocity 	= Vector2( 0.0, 0.0 )
	thrust   	= 0.0
	speed    	= 0.0
	reversing 	= false
	angular_friction = 0.0
	angular_velocity = 0.0
	orientation      = 0.0
	turning          = 0.0
	facing           = Vector2 ( 0.0, 0.0 )
	wheel_facing     = Vector2 ( 0.0, 0.0 )
	drag_vector      = Vector2 ( 0.0, 0.0 )
	drag             = 0.0
	skid_size_front  = 0.0
	skid_size_back   = 0.0
	collision_time = 0.0
	ghost_save_time = 0.0
	active = true
	
	
	match car_texture_number:
		1:
			$Pivot/body.texture = car_texture1

	
	$Pivot/body.rotation_degrees = 90


func _physics_process(delta):
	collision_time += delta
	
	if globals.started:
		ghost_save_time += delta
		if ghost_save_time > GHOST_SAVE_INTERVAL:
			globals.add_ghost_point(global_position, rotation, ghost_save_time)
			ghost_save_time = 0.0
#			print("Test" + String(globals.current_lap_ghost.size()))
	
	if speed > 10:
		skid_size_front = round( ( 1 - abs( wheel_facing.dot(velocity.normalized()) ) ) * 8 )
	else:
		skid_size_front = 0.0
	skid_size_back  = skid_size_front
	
	if active:
		process_input()
	
	thrust  = min( thrust * 0.95, 0.9 )
	turning = clamp( turning * 0.94, -1, 1 )
	
	angular_velocity += turning * ANGULAR_ACCELERATION
	angular_velocity += wheel_facing.angle_to( velocity ) * WOBBLE_RATE
	angular_velocity = clamp( angular_velocity, -MAX_ANGULAR_ACCELERATION, MAX_ANGULAR_ACCELERATION )
	angular_velocity *= angular_friction
	
	orientation      += angular_velocity * clamp ((facing * AGILITY_RATIO + wheel_facing * (1-AGILITY_RATIO) ).dot( velocity.normalized()), 0,1) * clamp(speed, 0, 1)
	wheel_facing = Vector2 ( cos( orientation + angular_velocity * 10 ), sin( orientation + angular_velocity * 10 ) )
	facing       = Vector2 ( cos( orientation ), sin( orientation ) ) 

	drag = ( 1 - abs( wheel_facing.dot(velocity.normalized()) )) * 0.02 + 0.01
	
	drag_vector = -velocity.rotated(wheel_facing.angle_to(velocity) * 0.4) * drag

	velocity += drag_vector
	velocity *= 1 - 0.05 * (1-facing.dot(velocity.normalized())) * (1-thrust)
	
	
	if velocity.length() > MAX_SPEED:
		velocity = velocity.normalized() * MAX_SPEED
	
	speed     = velocity.length()
	
	var collision = move_and_collide(velocity * delta, true, true, true)
	if collision and collision_time > 1.0:
		collision_time = 0.0
		$Camera2D.add_trauma( velocity.length() / MAX_SPEED )
		
		velocity *= 0.2
	velocity = move_and_slide(velocity)
	
	
	rotation = orientation
	$Pivot/pivot_left.rotation  = angular_velocity * 10
	$Pivot/pivot_right.rotation = angular_velocity * 10
	
	globals.speed = speed
#	get_parent().get_node("UI/Label").text = "Speed: %10.0f" % speed


	
func process_input():
	# turning
	angular_friction = ANGULAR_DAMPENING
	
	if player == 1:
		if Input.is_action_pressed("left"):
			if turning > 0:
				turning = 0
			turning -= STEERIN_TURNING
			angular_friction = 1
	
		if Input.is_action_pressed("right"):
			if turning < 0:
				turning = 0
			turning += STEERIN_TURNING
			angular_friction = 1
			
		# break
		if Input.is_action_pressed("down"):
			if reversing:
				thrust -= 0.06
				var thrust_limited = thrust * 60
				velocity += facing * ACCELERATION * thrust_limited * min( 1, abs( facing.dot( velocity.normalized() ) ) + 0.5 )
			
			else:
				if velocity.length() >= BREAKING:
					velocity       -= velocity.normalized() * BREAKING
					skid_size_front = 2
				else:
					velocity *= 0.0
					reversing = true
		# handbrake
		if Input.is_action_pressed("ui_select"):
			if velocity.length() >= BREAKING / 2:
				velocity -= velocity.normalized() * BREAKING / 2
				orientation -= facing.angle_to( velocity ) * 0.02 * min( 2, speed )
				skid_size_back = 5
		# accelerate
		if Input.is_action_pressed("up"):
			reversing = false
			
	#		if velocity.length() < MAX_SPEED:
			thrust += 0.06
			
			var thrust_limited = thrust * 60
			
			velocity += facing * ACCELERATION * thrust_limited * min( 1, abs( facing.dot( velocity.normalized() ) ) + 0.5 )
			skid_size_back = floor( max( 5 - speed / 2 , skid_size_back ) )
	
