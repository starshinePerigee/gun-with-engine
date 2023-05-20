extends Area2D

signal please_die(target: String)
signal laser_strength(strength: float)
signal laser_overheated
signal laser_cool

@export var max_laser = 2.0
var laser_cooling_down = false
var laser_heat = 0


# Called when the node enters the scene tree for the first time.
func _ready():
	z_index = 10


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):	
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) and not laser_cooling_down:
		self.show()
		$CollisionShape2D.disabled = false
		laser_heat = clamp(laser_heat + delta, 0.0, max_laser)
		if laser_heat >= max_laser:
			laser_overheated.emit()
			laser_cooling_down = true
	else:
		self.hide()
		$CollisionShape2D.disabled = true
		laser_heat = clamp(laser_heat - delta, 0.0, max_laser)
		if laser_heat <= 0:
			laser_cooling_down = false
			laser_cool.emit()
	laser_strength.emit(laser_heat / max_laser)


func _on_body_entered(body):
	please_die.emit(body.name)
