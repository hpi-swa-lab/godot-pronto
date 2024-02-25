@tool
#thumb("PlayStart")
extends Behavior
class_name NodeReadyBehavior
## The NodeReadyBehavior is a [class Behavior] that emits its [signal NodeReadyBehavior.node_ready]
## when the node's [NodeReadyBehavior._ready] was called and the node is still in the scene tree

## Emitted when the node is ready and still in the scene tree
signal node_ready

func _ready():
	super._ready()
	await get_tree().process_frame
	# we may have been removed from the tree
	if is_inside_tree():
		node_ready.emit()
