extends Node2D

signal take_damage()

@export var fire_rate = 10.0  # shots per second
var fire_delay
@export var lasergraphic: PackedScene

var last_position = Vector2()
var last_rotation = 0.0
var fire_remainder = 0.0


# Called when the node enters the scene tree for the first time.
func _ready():
	fire_delay = 1.0 / fire_rate


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	

func do_laser(delta):
	if not Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		$LeadingEdge.visible = false
		fire_remainder = 0.0
	else:
		$LeadingEdge.visible = true
		fire_remainder += delta
		
#		while fire_remainder >= fire_delay:
#			fire_remainder -= fire_delay
#			var lerp_weight = fire_remainder / delta  # int math
#			var start_point = last_position.lerp(global_position, lerp_weight)
#			var beam_angle = lerp_angle(last_rotation, global_rotation, lerp_weight)
#			var end_point = Vector2(cos(beam_angle), sin(beam_angle)) * 5000
#			end_point += start_point
#			graphic.points[0] = start_point
#			graphic.points[1] = end_point
		
		var far_point_old = Vector2(cos(last_rotation), sin(last_rotation)) * 5000 + last_position
		var far_point_new = Vector2(cos(global_rotation), sin(global_rotation)) * 5000 + global_position
		
		# special logic to handle if the polygon wants to cross itself
		var intersection = Geometry2D.segment_intersects_segment(last_position, far_point_old, global_position, far_point_new)
		if intersection:
			# these intersect so draw as two triangles
			var graphic_near = lasergraphic.instantiate()
			graphic_near.polygon[0] = intersection
			graphic_near.polygon[1] = global_position
			graphic_near.polygon[2] = last_position
			graphic_near.polygon[3] = intersection
			get_tree().get_root().add_child(graphic_near)
			var graphic_far = lasergraphic.instantiate()
			graphic_far.polygon[0] = intersection
			graphic_far.polygon[1] = far_point_old
			graphic_far.polygon[2] = far_point_new
			graphic_far.polygon[3] = intersection
			get_tree().get_root().add_child(graphic_far)
			$intersect.global_position = intersection
			$intersect.visible = true
		else:
			var graphic = lasergraphic.instantiate()
			# currently has a bug where the polygon can cross (such as ship moving with
			# constant mouse cursor)
			graphic.polygon[0] = last_position
			graphic.polygon[1] = global_position
			graphic.polygon[2] = far_point_new
			graphic.polygon[3] = far_point_old
			get_tree().get_root().add_child(graphic)
			$intersect.visible = false
		
	last_position = global_position
	last_rotation = global_rotation

#
#
#extends Area2D
#
#signal please_die(target: String)
#signal laser_strength(strength: float)
#signal laser_overheated
#signal laser_cool
#
#@export var max_laser = 2.0
#var laser_cooling_down = false
#var laser_heat = 0
#

## Called when the node enters the scene tree for the first time.
#func _ready():
#	pass
#
#
## Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):	
#	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) and not laser_cooling_down:
#		self.show()
#		$CollisionShape2D.disabled = false
#		laser_heat = clamp(laser_heat + delta, 0.0, max_laser)
#		if laser_heat >= max_laser:
#			laser_overheated.emit()
#			laser_cooling_down = true
#	else:
#		self.hide()
#		$CollisionShape2D.disabled = true
#		laser_heat = clamp(laser_heat - delta, 0.0, max_laser)
#		if laser_heat <= 0:
#			laser_cooling_down = false
#			laser_cool.emit()
#	laser_strength.emit(laser_heat / max_laser)
#
#
#func _on_body_entered(body):
#	please_die.emit(body.name)
