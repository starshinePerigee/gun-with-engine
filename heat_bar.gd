extends Node2D

@export var base_color = Color('a094ff')
@export var hot_color = Color('ff0000')
@export var max_width = 500
var height = 20


# Called when the node enters the scene tree for the first time.
func _ready():
	$ColorRect.size = Vector2(max_width, height)
	$ColorRect.color = base_color


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func set_size(width_factor):
	var new_size = Vector2(max_width * width_factor, height)
	$ColorRect.size = new_size

func overheat():
	$ColorRect.color = hot_color
	
func cooldown():
	$ColorRect.color = base_color
