extends RigidBody2D

var dangerous = true
@export var hit_points = 5


# Called when the node enters the scene tree for the first time.
func _ready():
	if get_parent() == get_tree().root:
		rotation = PI / 4
		position = Vector2(200, 200)
		apply_impulse(Vector2(200, 200))


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_visible_on_screen_notifier_2d_screen_exited():
	queue_free()


func take_damage(damage):
	hit_points -= damage
	if hit_points <= 0:
		die()


func die():
	hide()
	$Hitbox.disabled = true
	queue_free()
