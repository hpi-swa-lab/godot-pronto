extends Node2D

@export var scene: PackedScene

func spawn():
	var instance = scene.instantiate()
	instance.position = position
	get_parent().add_child(instance)
