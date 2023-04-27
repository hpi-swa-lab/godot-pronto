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
signal click(pos: Vector2)
signal moved(pos: Vector2)

func _is_key_pressed(direction):
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
	if event is InputEventMouseButton and event.pressed:
		click.emit(event.position)
	if event is InputEventMouseMotion:
		moved.emit(event.position)
