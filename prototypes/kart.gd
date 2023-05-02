extends CharacterBody2D

class HookPull:
	var target: Vector2
	var speed: float

var pull: HookPull = null

func set_hook_pull(target: Vector2, speed: float):
	pull = HookPull.new()
	pull.target = target
	pull.speed = speed

func _process(delta):
	if pull != null:
		position = position.move_toward(pull.target, delta * pull.speed)
