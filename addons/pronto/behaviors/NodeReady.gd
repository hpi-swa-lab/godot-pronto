@tool
#thumb("PlayStart")
extends Behavior
class_name NodeReady

signal node_ready

func _ready():
	super._ready()
	await get_tree().process_frame
	# we may have been removed from the tree
	if is_inside_tree():
		node_ready.emit()
