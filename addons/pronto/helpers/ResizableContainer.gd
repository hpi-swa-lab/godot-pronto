@tool
extends Control
class_name ResizableContainer
# Usage:
# Add a single child node to this node. The child node will be displayed with a handle that the user can drag to resize the child node.
# The child may customize handling of the resize by providing a `dragged_minimum_size` property and a `resize()` method.

# All resize handles within a specified parent can be synchronized.
@export var sync_handles_parent_path: NodePath = ^""
@export var sync_handles_x = false
@export var sync_handles_y = false

var child:
	get:
		# TODO: should we make the handle internal?
		return get_child(1) if get_child_count() > 1 else null

var _drag_start_offset = null

func _process(delta):
	# force layout of handle (workaround because it somehow always resizes with the parent)
	%Handle.set_size(Vector2(16, 16))
	
	if self.child == null:
		return
	# update handle position
	var rect = self.child.get_rect()
	%Handle.position = rect.size

func _gui_input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.is_pressed():
				var rect = %Handle.get_global_rect()
				if not rect.has_point(event.global_position):
					return
				_start_drag(event.global_position)
			else:
				_stop_drag()
	elif event is InputEventMouseMotion and _drag_start_offset != null:
		_drag(event.global_position)

func _start_drag(_position: Vector2):
	_drag_start_offset = _position - get_child_size()

func _stop_drag():
	_drag_start_offset = null

func _drag(_position: Vector2):
	if self.child == null:
		return
	set_child_size(_position - _drag_start_offset)
	
	# synchronize other containers
	if self.sync_handles_parent_path != ^"":
		var parent = get_node(self.sync_handles_parent_path)
		var other_containers = Utils.all_nodes_that(parent, func(node): return node is ResizableContainer and node != self)
		for other_container in other_containers:
			var other_child_size = other_container.get_child_size() + other_container.global_position
			if self.sync_handles_x:
				other_child_size.x = get_child_size().x + global_position.x
			if self.sync_handles_y:
				other_child_size.y = get_child_size().y + global_position.y
			other_container.set_child_size(other_child_size - other_container.global_position)

func get_child_size():
	return self.child.get_size()

func set_child_size(size: Vector2):
	if 'dragged_minimum_size' in self.child:
		self.child.dragged_minimum_size = size
		self.child.resize()
	else:
		self.child.set_size(size)
