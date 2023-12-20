@tool
#thumb("Joypad")
extends Behavior
class_name ControlsBehavior

## The ControlsBehavior is a [class Behavior] that encapsulates common
## control mechanisms for one of three players.

## Defines the available players
enum Player {
	Player_1 = 0, ## WASD
	Player_2 = 1, ## Arrow keys
	Player_3 = 2  ## IJKL
}

## Determines which player these controls are for. This determines the keys
## that the controls react to. Which keys that are is defined in [member ControlsBehavior.key_map]
##
## See [enum ControlsBehavior.Player] for possible values
@export var player: Player = Player.Player_1

## Emitted when the player's left key is pressed
signal left

## Emitted when the player's right key is pressed
signal right

## Emitted when the player's up key is pressed
signal up

## Emitted when the player's down key is pressed
signal down

## Emitted when any of the player's movement keys is pressed.
##
## [param direction] gives the direction as a normalized Vector2 depending on the keys that are pressed
signal direction(direction: Vector2)

## Emitted when any of the player's horizontal movement keys is pressed
##
## [param direction] gives the direction as
## [constant Vector2.LEFT] or [constant Vector2.RIGHT] or [constant Vector2.ZERO]
signal horizontal_direction(direction: Vector2)

## Emitted when any of the player's vertival movement keys is pressed
##
## [param direction] gives the direction as
## [constant Vector2.UP] or [constant Vector2.DOWN] or [constant Vector2.ZERO]
signal vertical_direction(direction: Vector2)

## Emitted when a mouse button was pressed.
##
## [param pos] gives the mouse position local to the viewport
##
## [param button] gives the mouse button that was pressed down
signal mouse_down(pos: Vector2, button: MouseButton)

## Emitted when a mouse button was raised.
##
## [param pos] gives the mouse position local to the viewport
##
## [param button] gives the mouse button that was raised
##
## [param duration] gives the duration in milliseconds that the button was pressed
signal mouse_up(pos: Vector2, button: MouseButton, duration: int)

## Emitted when the mouse moved.
##
## [param pos] gives the mouse position local to the viewport
signal mouse_move(pos: Vector2)

## Emitted when the mouse is moved while it is pressed.
##
## [param pos] gives the mouse position local to the viewport
signal mouse_drag(pos: Vector2)

## Emitted when a mouse button was pressed.
##
## [param pos] gives the global mouse position
##
## [param button] gives the mouse button that was pressed down
signal mouse_down_global(pos: Vector2, button: MouseButton)

## Emitted when a mouse button was raised.
##
## [param pos] gives the global mouse position
##
## [param button] gives the mouse button that was raised
##
## [param duration] gives the duration in milliseconds that the button was pressed
signal mouse_up_global(pos: Vector2, button: MouseButton, duration: int)

## Emitted when the mouse moved.
##
## [param pos] gives the global mouse position
signal mouse_move_global(pos: Vector2)

## Emitted when the mouse is moved while it is pressed.
##
## [param pos] gives the global mouse position
signal mouse_drag_global(pos: Vector2)

var enable_drag = false
var held_mouse_buttons = {}

## time in ms to wait after a key input to process the next input (0 for no throttle)
@export var input_throttle_delay = 0
var last_input_time = 0

#const valid_directions = ["left", "right", "up", "down"]
func _is_key_pressed(direction):
	#if not direction in valid_directions:
		#push_error("Direction must be one of {0} (got {1})".format(", ".join(valid_directions), direction))
	
	var action_string = "player_{0}_{1}".format([str(player), direction])
	return Input.is_action_pressed(action_string)

func _process(delta):
	super._process(delta)
	
	if Engine.is_editor_hint(): return
	
	# If throttling is enabled, discard input events until delay has passed
	var current_time = Time.get_ticks_msec()
	var discard_key_events = last_input_time + input_throttle_delay > current_time
	
	var input_direction = Vector2.ZERO # Used to allow vertical movement
	if _is_key_pressed("left") and not discard_key_events:
		left.emit()
		input_direction += Vector2.LEFT
		last_input_time = current_time
	if _is_key_pressed("right") and not discard_key_events:
		right.emit()
		input_direction += Vector2.RIGHT
		last_input_time = current_time
	if _is_key_pressed("up") and not discard_key_events:
		up.emit()
		input_direction += Vector2.UP
		last_input_time = current_time
	if _is_key_pressed("down") and not discard_key_events:
		down.emit()
		input_direction += Vector2.DOWN
		last_input_time = current_time
	# Emit signals
	vertical_direction.emit(Vector2(0, input_direction.y))
	horizontal_direction.emit(Vector2(input_direction.x, 0))
	input_direction = input_direction.normalized() # normalize vector after the vertical and horizontal signals
	direction.emit(input_direction)

func _input(event):
	if not can_process():
		return
	if event is InputEventMouseButton:
		if (event.button_index == MOUSE_BUTTON_LEFT):
			enable_drag = event.pressed
		if (event.pressed):
			held_mouse_buttons[event.button_index] = Time.get_ticks_msec();
			mouse_down.emit(event.position, event.button_index)
			mouse_down_global.emit(get_global_mouse_position(), event.button_index)
		else:
			mouse_up.emit(event.position, event.button_index, Time.get_ticks_msec() - held_mouse_buttons.get(event.button_index, 0))
			mouse_up_global.emit(get_global_mouse_position(), event.button_index, Time.get_ticks_msec() - held_mouse_buttons.get(event.button_index, 0))
			held_mouse_buttons.erase(event.button_index)
	if event is InputEventMouseMotion:
		mouse_move.emit(event.position)
		mouse_move_global.emit(get_global_mouse_position())
		if enable_drag:
			mouse_drag.emit(event.position)
			mouse_drag_global.emit(get_global_mouse_position())

func get_held_mouse_buttons():
	return held_mouse_buttons.keys()
