extends RigidBody2D 

signal firing_status(is_firing: bool)

@export var engine_power_factor = 800
var engine_thrust

@export var boost_impulse = 500  # little accelleration boost when stationary
@export var boost_threshold = 50  # threshold for boost to kick in

@export var rotation_degrees_per_second = 580
var max_rotation_radians = deg_to_rad(rotation_degrees_per_second)

var screen_size
var debug = false
@export var debug_weapon: PackedScene
var dying


# Called when the node enters the scene tree for the first time.
func _ready():
	screen_size = get_viewport_rect().size
	position = screen_size / 2
	engine_thrust = engine_power_factor * linear_damp
	
	contact_monitor = true
	max_contacts_reported = 1
	
	if get_parent() == get_tree().root:
		debug = true
		position = Vector2(200, 200)
		var weapon = debug_weapon.instantiate()
		weapon.rotation = -PI/2
		weapon.connect_weapon(self)
		add_child(weapon)


func apply_knockback(knockback):
	var knockback_vector = Vector2(cos(rotation+PI/2), sin(rotation+PI/2))
	apply_central_force(knockback_vector * knockback)


func _process(delta):
	pass


func _physics_process(delta):
	var firing = Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) or dying
	firing_status.emit(firing)


func _integrate_forces(state):
	if not dying:
		var input_vector = get_translation_input()

		check_apply_boost(input_vector)
		apply_input_force(input_vector)
		
		var target_rotation = get_target_angle(state)
		rotate_ship_clamped(state, target_rotation)
	
	clamp_edge_of_screen(state)


func get_translation_input():
	var input_vector = Vector2.ZERO
	if Input.is_action_pressed("ui_right"):
		input_vector.x += 1
	if Input.is_action_pressed("ui_left"):
		input_vector.x -= 1
	if Input.is_action_pressed("ui_up"):
		input_vector.y -= 1
	if Input.is_action_pressed("ui_down"):
		input_vector.y += 1
		
	input_vector = input_vector.normalized()
	return input_vector


func check_apply_boost(input_vector: Vector2):
	if linear_velocity.length() < boost_threshold:
		apply_central_impulse(input_vector * boost_impulse)


func apply_input_force(input_vector: Vector2):
	apply_central_force(input_vector * engine_thrust)


func clamp_edge_of_screen(state: PhysicsDirectBodyState2D):
	# handle being on the edge of the screen
	if position.x <= 0 or position.x >= screen_size.x:
		state.transform.origin.x = clamp(position.x, 0, screen_size.x)
		state.linear_velocity.x = 0 
		
	if position.y <= 0 or position.y >= screen_size.y:
		state.transform.origin.y = clamp(position.y, 0, screen_size.y)
		state.linear_velocity.y = 0


func get_target_angle(state: PhysicsDirectBodyState2D):
	# gets the angle from the center of the ship along the y axis to the mouse cursor
	
	# get the relative position of the cursor:
	var target_pos = get_global_mouse_position() - state.transform.origin
	
	# compensate for ship velocity
	target_pos -= state.linear_velocity * state.step
	
	# the ship is offset by 90 deg (the main axis points y+, so offset it by 90 deg
	var target_angle_offset = target_pos.angle() + PI/2
	# return with it modulo to -180 to +180
	return fmod(target_angle_offset + PI, 2*PI) - PI


func rotate_ship_clamped(state: PhysicsDirectBodyState2D, target_angle):
	# perform ship rotation
	var ideal_delta_angle = target_angle - global_rotation
	
	if ideal_delta_angle > PI:
		ideal_delta_angle -= 2*PI
	elif ideal_delta_angle < -PI:
		ideal_delta_angle += 2*PI
		
	var ideal_angular_velocity = ideal_delta_angle / state.step	
	var real_rotation = clamp(
		ideal_angular_velocity, -max_rotation_radians, max_rotation_radians
	)
	var new_rotation = state.transform.rotated(real_rotation * state.step)
	state.transform.x = new_rotation.x
	state.transform.y = new_rotation.y


func die():
	hide()
	$CollisionPolygon2D.set_deferred("disabled", true)
	$PlayerLaser.queue_free()
	

func _on_body_entered(body):
#	apply_torque_impulse(90)
	dying = true
	var timer = get_tree().create_timer(0.5)
	timer.timeout.connect(die)
