@tool
#thumb("Joypad")
extends Behavior
class_name ControlsBehavior

## The ControlsBehavior is a [class Behavior] that encapsulates common
## control mechanisms for one of three players.

## Defines the available players
enum Player {
	Player_1 = 0, ## Selecting this makes the controls react to the arrow keys
	Player_2 = 1, ## Selecting this makes the controls react to WASD
	Player_3 = 2  ## Selecting this makes the controls react to IJKL
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
## [param dir] gives the direction as 
## [constant Vector2.UP], [constant Vector2.DOWN], [constant Vector2.LEFT] or [constant Vector2.RIGHT]
signal direction(dir: Vector2)

## Emitted when any of the player's horizontal movement keys is pressed
##
## [param dir] gives the direction as
## [constant Vector2.LEFT] or [constant Vector2.RIGHT]
signal horizontal_direction(dir: Vector2)

## Emitted when any of the player's vertival movement keys is pressed
##
## [param dir] gives the direction as
## [constant Vector2.UP] or [constant Vector2.DOWN]
signal vertical_direction(dir: Vector2)

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

var key_map = [{
	"function": Input.is_action_pressed,
	"left": "ui_left",
	"right": "ui_right",
	"up": "ui_up",
	"down": "ui_down"
},
{
	"function": Input.is_physical_key_pressed,
	"left": KEY_A,
	"right": KEY_D,
	"up": KEY_W,
	"down": KEY_S
},
{
	"function": Input.is_physical_key_pressed,
	"left": KEY_J,
	"right": KEY_L,
	"up": KEY_I,
	"down": KEY_K
}]

func _is_key_pressed(direction):
	var keys = key_map[player]
	return keys["function"].call(keys[direction])

func _process(delta):
	super._process(delta)
	if _is_key_pressed("left"):
		left.emit()
		direction.emit(Vector2.LEFT)
		horizontal_direction.emit(Vector2.LEFT)
	if _is_key_pressed("right"):
		right.emit()
		direction.emit(Vector2.RIGHT)
		horizontal_direction.emit(Vector2.RIGHT)
	if _is_key_pressed("up"):
		up.emit()
		direction.emit(Vector2.UP)
		vertical_direction.emit(Vector2.UP)
	if _is_key_pressed("down"):
		down.emit()
		direction.emit(Vector2.DOWN)
		vertical_direction.emit(Vector2.DOWN)

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
