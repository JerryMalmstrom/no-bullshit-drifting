extends KinematicBody2D

var velocity 	= Vector2( 0.0, 0.0 )
var thrust   	= 0.0
var speed    	= 0.0
var reversing 	= false

const MAX_ANGULAR_ACCELERATION = 0.04
const ANGULAR_ACCELERATION     = 0.003
const STEERIN_TURNING          = 0.05
const AGILITY_RATIO            = 0.8   # 0-1
const ACCELERATION             = 0.30
const WOBBLE_RATE              = 0.001
const BREAKING                 = 10.0
const MAX_SPEED                = 1000.0

const ANGULAR_DAMPENING = 0.85

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
var polygon_time = 0.0

var polygon_track = PoolVector2Array()

var drift_size = 0.0

onready var color_tilemap = get_parent().get_node("Colors")
onready var skid_label = get_parent().get_node("CanvasLayer/Label")
onready var cover_label = get_parent().get_node("CanvasLayer/percent_covered")



func update_polygon(pos : Vector2):
	polygon_track.append(pos)
	get_parent().update_line(pos)

func clear_polygon():
	polygon_track.resize(0)
	
func color_polygon():
	if polygon_track.size() > 10:
		get_parent().update_pol(polygon_track)
	clear_polygon()
	get_parent().clear_line()

func _physics_process(delta):
	collision_time += delta
	polygon_time += delta
	
	if speed > 200:
		skid_size_front = round( ( 1 - abs( wheel_facing.dot(velocity.normalized()) ) ) * 8 )
	else:
		skid_size_front = 0.0

	skid_size_back  = skid_size_front

	
	if polygon_time > 0.2:
		polygon_time = 0.0
		skid_label.text = "Skid size: %.1f Speed: %.0f" % [drift_size, speed]
		cover_label.text = "Cover: %.1f" % color_tilemap.get_used_cells_by_id(0).size()
	
	drift_size = skid_size_front * speed / 500
	
	if drift_size > 1:
		color_tilemap.color_fixed_size(global_position, drift_size)
		
#
#	if polygon_time > 0.1:
#		polygon_time = 0.0
##		print(skid_size_front)
#		if skid_size_front > 1:
#			update_polygon(global_position)
#		else:
#			color_polygon()

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
		
		velocity *= 0.9
	velocity = move_and_slide(velocity)
	
	
	rotation = orientation
	$body/pivot_left.rotation  = angular_velocity * 10
	$body/pivot_right.rotation = angular_velocity * 10
#	update()

	

	
func process_input():
	# turning
	angular_friction = ANGULAR_DAMPENING
	if Input.is_action_pressed("ui_left"):
		if turning > 0:
			turning = 0
		turning -= STEERIN_TURNING
		angular_friction = 1

	if Input.is_action_pressed("ui_right"):
		if turning < 0:
			turning = 0
		turning += STEERIN_TURNING
		angular_friction = 1
		
	# break
	if Input.is_action_pressed("ui_down"):
		if reversing:
			thrust -= 0.06
			var thrust_limited = thrust * 60
			velocity += facing * ACCELERATION * thrust_limited * min( 1, abs( facing.dot( velocity.normalized() ) ) + 0.5 )
		
		else:
			if velocity.length() >= BREAKING:
				velocity       -= velocity.normalized() * BREAKING
				skid_size_front = 4
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
	if Input.is_action_pressed("ui_up"):
		reversing = false
		
#		if velocity.length() < MAX_SPEED:
		thrust += 0.06
		
		var thrust_limited = thrust * 60
		
		velocity += facing * ACCELERATION * thrust_limited * min( 1, abs( facing.dot( velocity.normalized() ) ) + 0.5 )
		skid_size_back = floor( max( 5 - speed / 2 , skid_size_back ) )

#func _draw():
#	draw_vector(Vector2(), velocity * 20, Color(1,1,1), 3)
#	draw_vector($body/pivot_right.global_position-position, wheel_facing * 40, Color(0,1,1), 2)
#	draw_vector($body/pivot_left.global_position-position, wheel_facing * 40, Color(0,1,1), 2)
#	draw_vector(Vector2(), facing  * 100, Color(1,0,1), 3)
#	draw_vector(Vector2(), drag_vector  * 1000, Color(0,1,0), 3)
#
#func draw_vector( origin, vector, color, arrow_size ):
#	if vector.length_squared() > 1:
#		var points    = []
#		var direction = vector.normalized()
#		vector += origin
#		vector -= direction * arrow_size*2
#		points.push_back( vector + direction * arrow_size*2  )
#		points.push_back( vector + direction.rotated(  PI / 1.5 ) * arrow_size * 2 )
#		points.push_back( vector + direction.rotated( -PI / 1.5 ) * arrow_size * 2 )
#		draw_polygon( PoolVector2Array( points ), PoolColorArray( [color] ) )
#		vector -= direction * arrow_size*1
#		draw_line( origin, vector, color, arrow_size )