@tool
#thumb("Loop")
extends Behavior

signal always(delta)

@export var paused = false:
	set(value): paused = value

func _process(delta):
	super._process(delta)
	
	if not Engine.is_editor_hint() and not paused:
		always.emit(delta)
