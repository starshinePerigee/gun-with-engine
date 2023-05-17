extends Area2D

signal please_die


# Called when the node enters the scene tree for the first time.
func _ready():
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		self.show()
		$CollisionShape2D.disabled = false
	else:
		self.hide()
		$CollisionShape2D.disabled = true


func _on_body_entered(body):
	if body.name == "RigidBody2D":
		please_die.emit()
		print("test")
		
