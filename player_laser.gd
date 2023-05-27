extends Node2D

signal take_damage()
signal knockback(knockback: int)

signal laser_heat_percent_is(strength: float)
signal laser_overheated
signal laser_cool

var laser_firing = true
var laser_locked = false
@export var fire_rate = 100.0  # shots per second
@export var damage = 1.0
var fire_delay
@export var damage_per_second = 100.0
var damage_per_ray
@export var lasergraphic: PackedScene

@export var laser_heat_capacity = 2.0
@export var laser_uptime = 0.5
var cooldown_factor = 1.0
var laser_cooling_down = false
var laser_heat = 0
@export var knockback_force = 6000

var raycast_params = PhysicsRayQueryParameters2D.new()

var last_position = Vector2()
var last_rotation = 0.0
var fire_remainder = 0.0

var debug = false


# Called when the node enters the scene tree for the first time.
func _ready():
	fire_delay = 1.0 / fire_rate
	cooldown_factor = laser_uptime / (1.0 - laser_uptime)
	damage_per_ray = damage_per_second / fire_rate
	
	# handling for debug
	if get_parent() == get_tree().root:
		debug = true
		position = Vector2(200, 200)
		$Intersect.visible = true
		$DamageRayDebug.visible = true
		$DamageRayDebug.top_level = true
	else:
		connect_weapon(get_parent())
		$DamageRayDebug.visible = false


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if debug:
		global_rotation = (get_global_mouse_position() - global_position).angle()
		laser_firing = Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT)
		laser_locked = false
		if Input.is_action_pressed("ui_right"):
			position.x = fmod((position.x + delta * 500 - 200), 800) + 200
		if not Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
			$DamageRayDebug.points = []
	do_laser(delta)
	
	last_position = global_position
	last_rotation = global_rotation


func do_laser(delta):
	if not laser_firing or laser_cooling_down or laser_locked:
		$LeadingEdge.visible = false
		fire_remainder = 0.0
		var total_cooldown = cooldown_factor * delta
		laser_heat = clamp(laser_heat - total_cooldown, 0.0, laser_heat_capacity)
		if laser_heat == 0:
			laser_cooling_down = false
			laser_cool.emit()
	else:
		$LeadingEdge.visible = true
		while fire_remainder <= delta:
			var lerp_weight = fire_remainder / delta
			var from_position = lerp(last_position, global_position, lerp_weight)
			var to_angle = lerp_angle(last_rotation, global_rotation, lerp_weight)
			var to_local_vector = Vector2.from_angle(to_angle) * 5000
			deal_damage(from_position, from_position+to_local_vector)
			fire_remainder += fire_delay
			
		fire_remainder -= delta
		
		laser_heat = clamp(laser_heat + delta, 0.0, laser_heat_capacity)
		if laser_heat >= laser_heat_capacity:
			laser_overheated.emit()
			laser_cooling_down = true
			laser_locked = true
		
		knockback.emit(knockback_force)
		draw_sweep()
	
	laser_heat_percent_is.emit(laser_heat / laser_heat_capacity)


func deal_damage(from: Vector2, to: Vector2):
	if debug:
		$DamageRayDebug.add_point(from)
		$DamageRayDebug.add_point(to)
		$DamageRayDebug.add_point(from)
	raycast_params.from = from
	raycast_params.to = to
	var space_state = get_world_2d().direct_space_state
	var results = space_state.intersect_ray(raycast_params)
	if results:
		results['collider'].take_damage(damage_per_ray)


func draw_sweep():
	var far_point_old = Vector2(cos(last_rotation), sin(last_rotation))
	far_point_old = far_point_old * 5000 + last_position
	var far_point_new = Vector2(cos(global_rotation), sin(global_rotation))
	far_point_new = far_point_new * 5000 + global_position

	# special logic to handle if the polygon wants to cross itself
	var intersection = Geometry2D.segment_intersects_segment(
			last_position, far_point_old, global_position, far_point_new
		)
	if intersection:
		# these intersect so draw as two triangles,
		# because a polygon crossing itself doesn't draw.
		var graphic_near = lasergraphic.instantiate()
		var near_poly = PackedVector2Array([
			intersection,
			global_position,
			last_position
		])
		graphic_near.polygon = near_poly
		get_tree().get_root().add_child(graphic_near)
		
		var graphic_far = lasergraphic.instantiate()
		var far_poly = PackedVector2Array([
			intersection,
			far_point_old,
			far_point_new
		])
		graphic_far.polygon = far_poly
		get_tree().get_root().add_child(graphic_far)
		if debug:
			$Intersect.global_position = intersection
			$Intersect.visible = true
	else:
		var graphic = lasergraphic.instantiate()
		var graph_poly = PackedVector2Array([
			last_position,
			global_position,
			far_point_new,
			far_point_old
		])
		graphic.polygon = graph_poly
		get_tree().get_root().add_child(graphic)
		if debug:
			$Intersect.visible = false


func _on_player_firing_status(is_firing):
	laser_firing = is_firing
	if not is_firing:
		laser_locked = false


func connect_weapon(parent):
	parent.firing_status.connect(_on_player_firing_status)
	knockback.connect(parent.apply_knockback)
	raycast_params.exclude += [parent]
