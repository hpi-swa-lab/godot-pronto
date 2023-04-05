extends Node2D

@export var scene: PackedScene

func spawn():
	var instance = scene.instantiate()
	instance.position = position
	get_parent().add_child(instance)

func spawn_toward(pos: Vector2):
	var instance: Node2D = scene.instantiate()
	instance.top_level = true
	instance.global_position = global_position
	instance.rotation = global_position.angle_to_point(pos)
	get_parent().add_child(instance)
