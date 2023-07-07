@tool
#thumb("GraphNode")
extends Behavior
class_name StateMachine

func _ready():
	super._ready()
	if Engine.is_editor_hint():
		add_child(preload("res://addons/pronto/helpers/GroupDrawer.tscn").instantiate(), false, INTERNAL_MODE_BACK)
