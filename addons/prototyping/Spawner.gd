@tool
extends TextureRect

var scene = null

func _ready():
	texture = Utils.icon_from_theme("GPUParticles3D", self)
	
	if not Engine.is_editor_hint():
		scene = get_child(0)
		remove_child(scene)

func spawn():
	var instance = scene.duplicate(DUPLICATE_USE_INSTANTIATION)
	instance.position = position + size / 2
	get_parent().add_child(instance)

func spawn_toward(pos: Vector2):
	var instance: Node2D = scene.duplicate(DUPLICATE_USE_INSTANTIATION | DUPLICATE_SCRIPTS | DUPLICATE_SIGNALS | DUPLICATE_GROUPS)
	instance.top_level = true
	instance.global_position = global_position + size / 2
	instance.rotation = global_position.angle_to_point(pos)
	get_parent().add_child(instance)
