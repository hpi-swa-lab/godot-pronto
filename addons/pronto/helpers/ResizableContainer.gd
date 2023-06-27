@tool
extends Control
class_name ResizableContainer

var child:
	get:
		#return get_child(1)
		# find a (potentially nested) child that has placeholder_text property
		return Utils.first_node_that(self, func(n): return n.has_method("update_editable"))

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	# move %Handle to bottom right corner of ourselves
	if self.child == null:
		return
	var rect = self.child.get_rect()
	%Handle.position = rect.size

func _gui_input(event):
	# drag %Handle
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.is_pressed():
				_start_drag(event.global_position)
			else:
				_stop_drag()
	elif event is InputEventMouseMotion and _drag_start_offset != null:
		_drag(event.global_position)

var _drag_start_offset = null

func _start_drag(_position: Vector2):
	_drag_start_offset = _position - self.child.get_size()

func _stop_drag():
	_drag_start_offset = null

func _drag(_position: Vector2):
	#%Handle.position = position - _drag_start_offset
	#self.child.set_size(Vector2.ZERO)
	#self.child.set_custom_minimum_size(_position - _drag_start_offset)
	#self.child.set_size(_position - _drag_start_offset)
	#self.child.position += Vector2.ZERO
	self.child.dragged_minimum_size = _position - _drag_start_offset
	self.child.resize()
