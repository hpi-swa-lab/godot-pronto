@tool
#thumb("Joypad")
extends Behavior

signal left
signal right
signal up
signal down
signal direction(dir: Vector2)
signal click(pos: Vector2)
signal moved(pos: Vector2)

func _process(delta):
	super._process(delta)
	
	if Input.is_action_pressed("ui_left"):
		left.emit()
		direction.emit(Vector2.LEFT)
	if Input.is_action_pressed("ui_right"):
		right.emit()
		direction.emit(Vector2.RIGHT)
	if Input.is_action_pressed("ui_up"):
		up.emit()
		direction.emit(Vector2.UP)
	if Input.is_action_pressed("ui_down"):
		down.emit()
		direction.emit(Vector2.DOWN)

func _input(event):
	if event is InputEventMouseButton and event.pressed:
		click.emit(event.position)
	if event is InputEventMouseMotion:
		moved.emit(event.position)
