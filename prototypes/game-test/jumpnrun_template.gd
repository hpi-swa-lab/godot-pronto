extends Node2D

var pressed = false

var key_map = {
	"function": Input.is_physical_key_pressed,
	"reset": KEY_SPACE
}

func _ready():
	pass

func restart_game():
	get_tree().reload_current_scene()
	
func _is_key_pressed(direction):
	var keys = key_map
	if (typeof(keys[direction]) == TYPE_ARRAY):
		return keys[direction].any(func(key): return keys["function"].call(key))
	else:
		return keys["function"].call(keys[direction])
		
		
func _physics_process(delta):
	if Engine.is_editor_hint():
		return
	if _is_key_pressed("reset"):
		pressed = true
	else:
		if pressed == true:
			get_tree().reload_current_scene()
			pressed = false
