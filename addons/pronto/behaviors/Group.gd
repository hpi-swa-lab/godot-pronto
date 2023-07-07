@tool
extends Behavior
#thumb("PointMesh")
class_name Group

# This node is purely visual.
# Use it for organization.

func _ready():
	super._ready()
	if Engine.is_editor_hint():
		add_child(preload("res://addons/pronto/helpers/GroupDrawer.tscn").instantiate(), false, INTERNAL_MODE_BACK)
