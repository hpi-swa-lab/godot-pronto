@tool
extends TextureRect

signal left
signal right
signal click(pos: Vector2)
signal moved(pos: Vector2)

func _ready():
	texture = Utils.icon_from_theme("Joypad", self)

func _process(delta):
	if Input.is_action_pressed("ui_left"):
		left.emit()
	if Input.is_action_pressed("ui_right"):
		right.emit()

func _input(event):
	if event is InputEventMouseButton and event.pressed:
		click.emit(event.position)
	if event is InputEventMouseMotion:
		moved.emit(event.position)
