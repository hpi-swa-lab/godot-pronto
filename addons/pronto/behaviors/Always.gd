@tool
#thumb("Loop")
extends Behavior

signal always(delta)
signal physiscs_always(delta)

@export var paused = false

func _process(delta):
	super._process(delta)
	
	if not Engine.is_editor_hint() and not paused:
		always.emit(delta)
		
func _physics_process(delta):
	if not Engine.is_editor_hint() and not paused:
		physiscs_always.emit(delta)
