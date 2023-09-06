extends Object
class_name U

## Collection of utilities for use in Expressions.

## For functions that act relative to a node, this sets the node.
var ref: Node

## Caches resolved nodes for looking up values from Stores or Values
var _at_cache = {}

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

### Alias for [member closest].
func c(name: String) -> Node:
	return closest(name)

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

func next_store(name: String):
	var key = (str(ref.get_path()) if ref else "") + ":" + name
	if key in _at_cache: return _at_cache[key]
	var s = closest_that(func (n): return n is StoreBehavior and n.has_meta(name))
	_at_cache[key] = G if s == null else s
	
	if s == null:
		return G
	else:
		return s

## Find the closest [Store] that has a field with [param name].
## If none is found, checks global state in [G].
## See [member closest_that].
func at(name: String, default = null) -> Variant: return next_store(name).at(name, default)

## Find the closest [Store] that has a field with [param name].
## If none is found, checks global state in [G].
## See [member closest_that].
func put(name: String, value: Variant) -> void: next_store(name).put(name, value)

func inc(name: String, amount = 1): next_store(name).inc(name, amount)
func dec(name: String, amount = 1): next_store(name).dec(name, amount)
