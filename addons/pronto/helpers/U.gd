extends Object
class_name U

# Collection of utilities for use in Expressions.

## For functions that act relative to a node, this sets the node.
var ref: Node

func _init(ref: Node = null):
	self.ref = ref

### Create an instance of these utils for the given node.
func u(ref: Node):
	return U.new(ref)

## Gets the parent of [member ref].
func get_parent() -> Node:
	return ref.get_parent()

## Find the closest node with the given name. See [member closest_that].
func closest(name: String) -> Node:
	return closest_that(func (n): return n.name == name)

## Find the closest node that matches the given criterium. First checks children, then children of parents
## in a breadth-first search.
func closest_that(cond: Callable) -> Node:
	var root = ref
	var last = null
	while root != null:
		var queue = [root]
		while not queue.is_empty():
			var current = queue.pop_front()
			if cond.call(current):
				return current
			# append all children except for the subtree that we explored last already
			queue.append_array(current.get_children().filter(func (n): return n != last))
		
		last = root
		root = root.get_parent()
	return null

## Returns all nodes in the given group.
static func group(name: String) -> Array[Node]:
	return Engine.get_main_loop().get_nodes_in_group(name)

## Run cb for all nodes in the given group.
static func group_do(name: String, cb: Callable) -> void:
	for n in group(name): cb.call(n)

## Return the size of the game screen.
static func screen_size() -> Vector2:
	return Vector2(ProjectSettings.get_setting("display/window/size/viewport_width"), ProjectSettings.get_setting("display/window/size/viewport_height"))

## Return a random point on the game screen.
static func random_point_on_screen() -> Vector2:
	return Vector2(randf(), randf()) * screen_size()

## Return the position of the mouse on the game screen.
static func mouse_position() -> Vector2:
	return Engine.get_main_loop().root.get_mouse_position()

## Find the closest [State] that has a field with [param name].
## If none is found, checks global state in [G].
## See [member closest_that].
func at(name: String, default = null) -> Variant:
	var state = closest_that(func (n): return n is State and n.has_meta(name))
	return state.at(name, default) if state != null else G.at(name, default)

## Find the closest [State] that has a field with [param name].
## If none is found, checks global state in [G].
## See [member closest_that].
func put(name: String, value: Variant) -> void:
	var state = closest_that(func (n): return n is State and n.has_meta(name))
	if state != null:
		state.put(name, value)
	else:
		print("STORING IN GLOBAL " + name)
		G.put(name, value)
