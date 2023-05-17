extends Node2D

@export var speed = 650
@export var rotation_degrees_per_second = 420

var max_rotation_radians = deg_to_rad(rotation_degrees_per_second)

var screen_size

# Called when the node enters the scene tree for the first time.
func _ready():
	screen_size = get_viewport_rect().size
	position = screen_size / 2


func get_target_angle():
	# gets the angle from the center of the ship along the y axis to the mouse cursor
	
	# get the angle of the cursor:
	var target_angle_raw = (get_global_mouse_position() - global_position).angle()
	# the ship is offset by 90 deg (the main axis points y+, so offset it by 90 deg
	var target_angle_offset = target_angle_raw + PI/2
	# return with it modulo to -180 to +180
	return fmod(target_angle_offset + PI, 2*PI) - PI


func rotate_ship_clamped(delta, target_angle):
	# perform ship rotation
	var ideal_delta_angle = target_angle - global_rotation
	
	if ideal_delta_angle > PI:
		ideal_delta_angle -= 2*PI
	elif ideal_delta_angle < -PI:
		ideal_delta_angle += 2*PI
		
	var ideal_angular_velocity = ideal_delta_angle / delta	
	var real_rotation = clamp(
		ideal_angular_velocity, -max_rotation_radians, max_rotation_radians
	)
	global_rotation += real_rotation * delta


func move_ship(delta):
	var velocity = Vector2.ZERO
	if Input.is_action_pressed("ui_right"):
		velocity.x += 1
	if Input.is_action_pressed("ui_left"):
		velocity.x -= 1
	if Input.is_action_pressed("ui_up"):
		velocity.y -= 1
	if Input.is_action_pressed("ui_down"):
		velocity.y += 1
		
	if velocity.length() > 0:
		velocity = velocity.normalized() * speed
		
	position += velocity * delta
	position.x = clamp(position.x, 0, screen_size.x)
	position.y = clamp(position.y, 0, screen_size.y)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	rotate_ship_clamped(delta, get_target_angle())
	move_ship(delta)


func _on_area_2d_body_entered(body):
	if body.name == "RigidBody2D":
		hide()
		$Area2D/CollisionPolygon2D.set_deferred("disabled", true)
