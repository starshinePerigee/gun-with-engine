extends Line2D

@export var start_color = Color8(255, 0, 136)
@export var cool_color = Color8(90, 0, 80)
@export var end_color = Color8(0, 14, 36)
@export var lifespan = 3.0
@export var cooltime = 0.1
var time = 0


# Called when the node enters the scene tree for the first time.
func _ready():
	z_index = 10
	default_color = start_color


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	time += delta
	if time >= cooltime:
		z_index = -10
		default_color = cool_color.lerp(end_color, time / lifespan)
	if time >= lifespan:
		visible = false
		queue_free()
