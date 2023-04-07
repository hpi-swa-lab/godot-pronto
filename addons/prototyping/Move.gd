@tool
extends TextureRect

@export var speed = 500.0
@export var rotated = false

func _ready():
	texture = Utils.icon_from_theme("ToolMove", self)

func move_left():
	get_parent().position -= speed_vector(true)

func move_right():
	get_parent().position += speed_vector(true)

func move_down():
	get_parent().position += speed_vector(false)

func move_up():
	get_parent().position -= speed_vector(false)

func move_toward(pos: Vector2):
	get_parent().position += (pos - get_parent().global_position).normalized() * speed

func speed_vector(horizontal: bool):
	var s = speed * get_process_delta_time()
	var v = Vector2(s if horizontal else 0, 0 if horizontal else s)
	if rotated:
		return v.rotated(get_parent().rotation)
	else:
		return v
