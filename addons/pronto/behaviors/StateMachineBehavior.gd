@tool
#thumb("GraphNode")
extends Behavior
class_name StateMachineBehavior

## The StateMachineBehavior is a [class Behavior] that acts as a purely graphic
## hint as to which [class StateBehavior] objects belong to the same state machine.
## The [class GroupDrawer] is used for this.

func _ready():
	super._ready()
	if Engine.is_editor_hint():
		add_child(preload("res://addons/pronto/helpers/GroupDrawer.tscn").instantiate(), false, INTERNAL_MODE_BACK)
