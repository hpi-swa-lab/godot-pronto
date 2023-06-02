extends CharacterBody2D

@onready var _follow :PathFollow2D = get_parent()
@export var _speed :float = 120.0

func _physics_process(delta):
	_follow.set_progress(_follow.get_progress() + _speed * delta)
