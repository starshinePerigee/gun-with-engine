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
	if not Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		fire_remainder = 0.0
	else:
		fire_remainder += delta
		
		while fire_remainder >= fire_delay:
			fire_remainder -= fire_delay
			var graphic = lasergraphic.instantiate()
			graphic.time = delta - fire_remainder
			var lerp_weight = fire_remainder / delta  # int math
			var start_point = last_position.lerp(global_position, lerp_weight)
			var beam_angle = lerp_angle(last_rotation, global_rotation, lerp_weight)
			var end_point = Vector2(cos(beam_angle), sin(beam_angle)) * 5000
			end_point += start_point
			graphic.points[0] = start_point
			graphic.points[1] = end_point
		
			get_tree().get_root().add_child(graphic)
		
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
