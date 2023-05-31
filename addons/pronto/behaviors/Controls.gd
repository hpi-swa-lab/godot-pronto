@tool
#thumb("Joypad")
extends Behavior

@export_enum("Player 1", "Player 2", "Player 3") var player: int = 0

signal left
signal right
signal up
signal down
signal direction(dir: Vector2)
signal horizontal_direction(dir: Vector2)
signal vertical_direction(dir: Vector2)

signal mouse_down(pos: Vector2, button: MouseButton)
signal mouse_up(pos: Vector2, button: MouseButton, duration: int)
signal mouse_move(pos: Vector2)
signal mouse_drag(pos: Vector2)

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
	if event is InputEventMouseButton:
		if (event.button_index == MOUSE_BUTTON_LEFT):
			enable_drag = event.pressed
		if (event.pressed):
			held_mouse_buttons[event.button_index] = Time.get_ticks_msec();
			mouse_down.emit(event.position, event.button_index)
		else:
			mouse_up.emit(event.position, event.button_index, Time.get_ticks_msec() - held_mouse_buttons.get(event.button_index, 0))
			held_mouse_buttons.erase(event.button_index)
	if event is InputEventMouseMotion:
		mouse_move.emit(event.position)
		if enable_drag:
			mouse_drag.emit(event.position)

func get_held_mouse_buttons():
	return held_mouse_buttons.keys()
