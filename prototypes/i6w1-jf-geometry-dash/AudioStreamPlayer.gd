extends AudioStreamPlayer

var global_position
# Called when the node enters the scene tree for the first time.
func _ready():
	global_position = get_parent().global_position


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
