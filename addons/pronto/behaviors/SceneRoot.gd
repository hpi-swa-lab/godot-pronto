@tool
#thumb("ClassList")
extends Behavior
class_name SceneRoot

## Allows for easy access of the SceneTree.

var scene_tree: SceneTree

signal node_added(node: Node)
signal node_removed(node: Node)
signal tree_changed()

func _ready():
	super._ready()
	scene_tree = get_tree()
	scene_tree.node_added.connect(func(node): node_added.emit(node))
	scene_tree.node_removed.connect(func(node): node_removed.emit(node))
	scene_tree.tree_changed.connect(func(): tree_changed.emit())

# For future changes of all functions beginning with "apply" it is immportant
# to also change the corresponding lines in "node_to_node_configuration.gd::_on_function_selected"
# and "Connection.gd::_trigger".

## This will execute 'lamda_func' on all group elements in the given group.
func apply(group: StringName, lamda_func: Callable, from: Node2D):
	for node in scene_tree.get_nodes_in_group(group):
		lamda_func.call(from, node)
		
## This will execute 'lamda_func' on all group elements in the given group, where 'filter_func'
## evaluates to true.
func apply_with_filter(group: StringName, lamda_func: Callable, filter_func: Callable, from: Node2D):
	for node in scene_tree.get_nodes_in_group(group):
		if filter_func.call(from, node):
			lamda_func.call(from, node)

## This will execute 'lamda_func' on all group elements in the given group, that have a maximum
## distance of 'max_dist' from the provied position.
func apply_within_dist(group: StringName, lamda_func: Callable, position: Vector2, max_dist: float, from: Node2D):
	for node in scene_tree.get_nodes_in_group(group):
		if node.global_position.distance_to(position) <= max_dist:
			lamda_func.call(from, node)
	
func notify_group(group: StringName, notification: int):
	scene_tree.notify_group(group, notification)

func notify_group_flags(call_flags: int, group: StringName, notification: int):
	scene_tree.notify_group_flags(call_flags, group, notification)
	
func reload_current_scene():
	scene_tree.reload_current_scene()
	
func set_group(group: StringName, property: String, value: Variant):
	scene_tree.set_group(group, property, value)
	
func set_group_flags(call_flags: int, group: StringName, property: String, value: Variant):
	scene_tree.set_group_flags(call_flags, group, property, value)
	
func quit(exit_code: int = 0):
	scene_tree.quit(exit_code)
	
func unload_current_scene():
	scene_tree.unload_current_scene()
