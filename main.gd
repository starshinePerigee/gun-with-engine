extends Node2D

@export var enemy_scene: PackedScene
@export var average_enemy_speed = 300
@export var enemy_speed_variation = 100


# Called when the node enters the scene tree for the first time.
func _ready():
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_spawn_timer_timeout():
	var mob = enemy_scene.instantiate()
	var mob_spawn_location = get_node("MobPath/MobSpawnLocation")
	mob_spawn_location.progress_ratio = randf()
#
	var direction = mob_spawn_location.rotation + PI / 2
	mob.position = mob_spawn_location.position
#
	direction += randf_range(-PI / 4, PI / 4)
	mob.rotation = direction
#
	var velocity = Vector2(randf_range(
		average_enemy_speed - enemy_speed_variation / 2,
		average_enemy_speed + enemy_speed_variation / 2
	), 0.0)
	mob.linear_velocity = velocity.rotated(direction)

	add_child(mob)
