@tool
#thumb("Joypad")
extends Behavior

@export var use_WASD = false

signal left
signal right
signal up
signal down
signal direction(dir: Vector2)
signal horizontal_direction(dir: Vector2)
signal vertical_direction(dir: Vector2)
signal click(pos: Vector2)
signal moved(pos: Vector2)

func _process(delta):
	super._process(delta)
	if (use_WASD):
		if Input.is_physical_key_pressed(KEY_A):
			left.emit()
			direction.emit(Vector2.LEFT)
			horizontal_direction.emit(Vector2.LEFT)
		if Input.is_physical_key_pressed(KEY_D):
			right.emit()
			direction.emit(Vector2.RIGHT)
			horizontal_direction.emit(Vector2.RIGHT)
		if Input.is_physical_key_pressed(KEY_W):
			up.emit()
			direction.emit(Vector2.UP)
			vertical_direction.emit(Vector2.UP)
		if Input.is_physical_key_pressed(KEY_S):
			down.emit()
			direction.emit(Vector2.DOWN)
			vertical_direction.emit(Vector2.DOWN)
	else:
		if Input.is_action_pressed("ui_left"):
			left.emit()
			direction.emit(Vector2.LEFT)
			horizontal_direction.emit(Vector2.LEFT)
		if Input.is_action_pressed("ui_right"):
			right.emit()
			direction.emit(Vector2.RIGHT)
			horizontal_direction.emit(Vector2.RIGHT)
		if Input.is_action_pressed("ui_up"):
			up.emit()
			direction.emit(Vector2.UP)
			vertical_direction.emit(Vector2.UP)
		if Input.is_action_pressed("ui_down"):
			down.emit()
			direction.emit(Vector2.DOWN)
			vertical_direction.emit(Vector2.DOWN)

func _input(event):
	if event is InputEventMouseButton and event.pressed:
		click.emit(event.position)
	if event is InputEventMouseMotion:
		moved.emit(event.position)
