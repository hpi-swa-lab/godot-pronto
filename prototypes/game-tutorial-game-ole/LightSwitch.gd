extends Area2D


# Called when the node enters the scene tree for the first time.
func _ready():
	var lightswitch_x = randf_range(100, 1200) #all values are 100 away from boundary
	var lightswitch_y = randf_range(100, 500)
	set_global_position(Vector2(lightswitch_x, lightswitch_y))
	get_node("SwitchPlaceholderBehavior").set_global_position(Vector2(lightswitch_x, lightswitch_y))


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
