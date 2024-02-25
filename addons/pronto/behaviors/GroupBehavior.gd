@tool
extends Behavior
#thumb("PointMesh")
class_name GroupBehavior
## The GroupBehavior is a [class Behavior] that visually represents
## a group of notes. It has no further functionality. Use it for organization.

func _ready():
	super._ready()
	if Engine.is_editor_hint():
		add_child(preload("res://addons/pronto/helpers/GroupDrawer.tscn").instantiate(), false, INTERNAL_MODE_BACK)
