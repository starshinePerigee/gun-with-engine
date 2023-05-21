extends Node2D

signal take_damage()

signal laser_heat_percent_is(strength: float)
signal laser_overheated
signal laser_cool

var laser_firing = true
var laser_locked = false
@export var fire_rate = 10.0  # shots per second
var fire_delay
@export var lasergraphic: PackedScene

@export var laser_heat_capacity = 2.0
@export var laser_uptime = 0.5
var cooldown_factor = 1.0
var laser_cooling_down = false
var laser_heat = 0

var last_position = Vector2()
var last_rotation = 0.0
var fire_remainder = 0.0


# Called when the node enters the scene tree for the first time.
func _ready():
	fire_delay = 1.0 / fire_rate
	cooldown_factor = laser_uptime / (1.0 - laser_uptime)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	do_laser(delta)
	

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
		fire_remainder += delta
		laser_heat = clamp(laser_heat + delta, 0.0, laser_heat_capacity)
		if laser_heat >= laser_heat_capacity:
			laser_overheated.emit()
			laser_cooling_down = true
			laser_locked = true
		
#		while fire_remainder >= fire_delay:
#			fire_remainder -= fire_delay
#			var lerp_weight = fire_remainder / delta  # int math
#			var start_point = last_position.lerp(global_position, lerp_weight)
#			var beam_angle = lerp_angle(last_rotation, global_rotation, lerp_weight)
#			var end_point = Vector2(cos(beam_angle), sin(beam_angle)) * 5000
#			end_point += start_point
#			graphic.points[0] = start_point
#			graphic.points[1] = end_point
		
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
#			$Intersect.global_position = intersection
#			$Intersect.visible = true
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
#			$Intersect.visible = false
		
	last_position = global_position
	last_rotation = global_rotation
	
	laser_heat_percent_is.emit(laser_heat / laser_heat_capacity)


func _on_player_firing_status(is_firing):
	laser_firing = is_firing
	if not is_firing:
		laser_locked = false
