@tool
#thumb("Mouse")
extends Behavior
class_name DragBehavior

## The DragBehavior is a [class Behavior] that encapsulates mouse movement bahavior
## on its parent node.

## Emitted when the mouse enters the parent node.
##
## [param position] is the global position where the mouse entered the parent node
signal mouse_entered(position: Vector2)

## Emitted when the mouse leaves the parent node.
##
## [param position] is the global position where the mouse exited the parent node
signal mouse_exited(position: Vector2)

## Emitted when picked up by clicking
##
## [param position] is the global position of the parent node.
signal picked(position: Vector2)

## Emitted when dropping
##
## [param position] is the global position of the parent node.
##
## [param  start_position] is the parent's global position at the start of dragging 
signal dropped(position: Vector2, start_position: Vector2)

## Emitted during dragging
##
## [param position] is the global position of the parent node
##
## [param start_position] is the global position at which 
## the parent node was started to be dragged
##
## [param last_position] is the global position where the last movement
## of the parent started
signal dragged(position: Vector2, start_position: Vector2, last_position: Vector2)

@export_flags("Left", "Right", "Middle") var button_mask := 1

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
	mouse_entered.emit(position)

func _mouse_exit(position: Vector2):
	mouse_exited.emit(position)

func _pick(position: Vector2):
	picked.emit(position)
	start_position = position
	last_position = position

	if get_parent() is RigidBody2D:
		get_parent().freeze = true
	
func _drag(position: Vector2):
	get_parent().global_position = position + _offset
	dragged.emit(position, start_position, last_position)
	last_position = position
	
func _drop(position: Vector2):
	if get_parent() is RigidBody2D:
		get_parent().freeze = false
		get_parent().apply_central_impulse(Input.get_last_mouse_velocity())
	
	dropped.emit(position, start_position)
