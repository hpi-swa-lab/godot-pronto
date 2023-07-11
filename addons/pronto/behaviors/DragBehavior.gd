@tool
#thumb("Mouse")
extends Behavior
class_name DragBehavior


## Emitted when the mouse enters the parent node.
signal mouse_entered(position: Vector2)

## Emitted when the mouse leaves the parent node.
signal mouse_exited(position: Vector2)

## Emitted when picked up by clicking
## Position is the global position of the parent node.
signal picked(position: Vector2)

## Emitted when dropping
## Position and start_position are the global position of the parent node and its position at the start of dragging 
signal dropped(position: Vector2, start_position: Vector2)

## Emitted during dragging
## All positions are the global position of the parent node.
## Last position is the last position the parent node was move from.
signal dragged(position: Vector2, start_position: Vector2, last_position: Vector2)

@export_flags("Left", "Middle", "Right") var button_mask := 1

## Offset of parent node from mouse position
var _offset

var last_position : Vector2
var start_position : Vector2

var is_hovering_parent = false


func _unhandled_input(event: InputEvent):
	if not (event is InputEventMouseButton or event is InputEventMouseMotion):
		return
	
	var parent_position := get_parent().global_position as Vector2
	var event_position := event.global_position as Vector2
	if event is InputEventMouseMotion:
		#print("motion:", event, new_hovering, is_hovering_parent)
		if _offset != null:
			_drag(event_position)
		var new_hovering = _is_position_over_parent(event.global_position)
		if new_hovering != is_hovering_parent:
			is_hovering_parent = new_hovering
			if new_hovering:
				_mouse_enter(event_position)
			else:
				_mouse_exit(event_position)
		return
	elif event is InputEventMouseButton:
		var new_hovering = _is_position_over_parent(event.global_position)
		if not (button_mask & (1 << (event.button_index - 1))):  # event.button_index is not set on mouseUp
			return
		if event.pressed:
			if not new_hovering:
				return
			_offset = parent_position - event_position
			_pick(event_position)
		elif _offset != null:
			_offset = null
			_drop(event_position)
		else:
			return
	else:
		return
	
	get_viewport().set_input_as_handled()

func _is_position_over_parent(position: Vector2) -> bool:
	var parent_rect := Utils.global_rect_of(get_parent(), 1, [self]) as Rect2
	var over := parent_rect.has_point(position)
	return over

func _mouse_enter(position: Vector2):
	print("Mouse enter")
	mouse_entered.emit(position)

func _mouse_exit(position: Vector2):
	print("Mouse exit")
	mouse_exited.emit(position)

func _pick(position: Vector2):
	print("Pick")
	picked.emit(position)
	start_position = position
	last_position = position
	
func _drag(position: Vector2):
	get_parent().global_position = position + _offset
	dragged.emit(position, start_position, last_position)
	last_position = position
	
func _drop(position: Vector2):
	print("Drop")
	dropped.emit(position, start_position)
