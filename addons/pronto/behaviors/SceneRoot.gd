@tool
#thumb("ClassList")
extends Behavior

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
	
func apply(group: StringName, lamda_func: Callable):
	for node in scene_tree.get_nodes_in_group(group):
		lamda_func.call(node)
	
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
