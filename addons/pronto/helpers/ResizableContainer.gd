@tool
extends Control
class_name ResizableContainer
# Usage:
# Add a single child node to this node. The child node will be displayed with a handle that the user can drag to resize the child node.

var child:
	get:
		# TODO: should we make the handle internal?
		return get_child(1) if get_child_count() > 1 else null

var _drag_start_offset = null

func _process(delta):
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
	_drag_start_offset = _position - self.child.get_size()

func _stop_drag():
	_drag_start_offset = null

func _drag(_position: Vector2):
	if self.child == null:
		return
	if 'dragged_minimum_size' in self.child:
		self.child.dragged_minimum_size = _position - _drag_start_offset
		self.child.resize()
	else:
		self.child.set_size(_position - _drag_start_offset)
