extends Timer


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_start_timer_timeout():
	wait_time -= 0.01
	if wait_time < 0.05:
		wait_time = 0.05
	start()
