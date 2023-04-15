@tool
extends Behavior

var scene = null

func _ready():
	super._ready()
	
	if not Engine.is_editor_hint():
		scene = get_child(0)
		remove_child(scene)

func _spawn():
	return scene.duplicate(DUPLICATE_USE_INSTANTIATION | DUPLICATE_SCRIPTS | DUPLICATE_SIGNALS | DUPLICATE_GROUPS)

func spawn():
	var instance = _spawn()
	instance.position = position + size / 2
	get_parent().add_child(instance)

func spawn_toward(pos: Vector2):
	var instance = _spawn()
	instance.top_level = true
	instance.global_position = global_position + size / 2
	instance.rotation = global_position.angle_to_point(pos)
	get_parent().add_child(instance)
