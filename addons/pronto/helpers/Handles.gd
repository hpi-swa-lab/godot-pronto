@tool
extends Object
class_name Handles

var _dragging = null

class Handle:
	var position: Vector2
	var icon: Texture
	var apply: Callable
	var local_space: bool
	
	func _init(position: Vector2, icon: Texture, apply: Callable, local_space = true):
		self.position = position
		self.icon = icon
		self.apply = apply
		self.local_space = local_space
	
	func rect_in(node: CanvasItem):
		return Rect2(
			node.get_viewport_transform() * node.get_canvas_transform() * (node.global_position + (position if local_space else Vector2.ZERO)) - icon.get_size() / 2 + (Vector2.ZERO if local_space else position),
			icon.get_size())
	
	func begin():
		pass
	
	func end(undo_redo):
		pass

class SetPropHandle extends Handle:
	var property: String
	var object: Object
	var map: Callable
	var _initial: Variant
	
	func _init(position: Vector2, icon: Texture, object: Object, property: String, map: Callable, local_space = true):
		super._init(
			position, 
			icon, 
			func (new_prop):
				object.set(property, map.call(new_prop)), 
			local_space
		)
		self.object = object
		self.property = property
		self.map = map
	
	func begin():
		_initial = object.get(property)
	
	func end(undo_redo):
		undo_redo.create_action("Set {0}".format([property]))
		undo_redo.add_do_property(object, property, object.get(property))
		undo_redo.add_undo_property(object, property, _initial)
		undo_redo.commit_action(false)

func deselected():
	_dragging = null

func _forward_canvas_draw_over_viewport(node: Behavior, viewport_control: Control):
	if node.handles():
		for handle in node.handles():
			viewport_control.draw_texture(handle.icon, handle.rect_in(node).position)

func _forward_canvas_gui_input(node: Behavior, event: InputEvent, undo_redo):
	if event is InputEventMouse:
		if _dragging != null:
			if event is InputEventMouseButton and not event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
				_dragging.end(undo_redo)
				_dragging = null
				return true
			if event is InputEventMouseMotion:
				if _dragging.local_space:
					_dragging.apply.call(node.get_viewport().get_global_canvas_transform().affine_inverse() * event.position -  node.global_position)
				else:
					_dragging.apply.call(event.position - node.get_viewport_transform() * node.global_position)
				return true
		if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			if node.handles():
				for handle in node.handles():
					if handle.rect_in(node).has_point(event.position):
						_dragging = handle
						_dragging.begin()
						return true
	return false
