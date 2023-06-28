@tool
#thumb("GraphNode")
extends Behavior
class_name State

signal entered
signal exited(transition_id: int)

@export var active: bool = false:
	get: return active
	set(value): active = value

func enter():
	if not active:
		active = true
		entered.emit()

func exit(transition_id):
	if active:
		active = false
		exited.emit(transition_id)

func _init():
	pass

func _process(delta):
	pass
