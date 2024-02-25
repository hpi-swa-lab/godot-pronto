@tool
#thumb("Loop")
extends Behavior
class_name AlwaysBehavior
## The AlwaysBehavior is a [class Behavior] that emits signals every frame.
## 
## See [signal AlwaysBehavior.always] and [signal AlwaysBehavior.physics_always] for 
## a description of which signal to listen to.

## This Signal gets emitted every frame in the [method AlwaysBehavior._process] method
## if [member AlwaysBehavior.paused] is set to [code]false[/code]
signal always(delta)

## This Signal gets emitted every frame in the [method AlwaysBehavior._physics_process] method
## if [member AlwaysBehavior.paused] is set to [code]false[/code]
signal physiscs_always(delta)

## If this is set to [code]true[/code] the AlwaysBehavior will stop emitting any
## signals. During runtime, do not set this directly. Instead use [method AlwaysBehavior.pause] 
## and [method AlwaysBehavior.resume]
@export var paused = false

func _process(delta):
	super._process(delta)
	
	if not Engine.is_editor_hint() and not paused:
		always.emit(delta)
		
func _physics_process(delta):
	if not Engine.is_editor_hint() and not paused:
		physiscs_always.emit(delta)

## Calling this method results in pausing the execution of always
## Use [method AlwaysBehavior.resume] to continue the execution
func pause():
	paused = true

## Calling this method results in continuing the paused execution
## Use [method AlwaysBehavior.pause] to stop it again.
func resume():
	paused = false
