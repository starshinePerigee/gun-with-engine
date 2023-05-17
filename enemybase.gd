extends Node2D

var dangerous = true


# Called when the node enters the scene tree for the first time.
func _ready():
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_visible_on_screen_notifier_2d_screen_exited():
	queue_free()


func die():
	print("am dead")
	hide()
	$RigidBody2D/CollisionPolygon2D.disabled = true
