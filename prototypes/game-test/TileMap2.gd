extends TileMap


func _ready():
	turn_off_lights()

func turn_off_lights():
	for child in get_children():
		if child is PointLight2D:
			child.enabled = false

func turn_on_lights():
	for child in get_children():
		if child is PointLight2D:
			child.enabled = true

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
