@tool
#thumb("ToolMove")
extends Behavior

@export var speed = 500.0
@export var rotation_speed = 300.0
@export var rotated = false

func move_direction(direction: Vector2):
	get_parent().position += _speed_vector_dir(direction)

func move_left():
	get_parent().position -= _speed_vector(true)

func move_right():
	get_parent().position += _speed_vector(true)

func move_down():
	get_parent().position += _speed_vector(false)

func move_up():
	get_parent().position -= _speed_vector(false)

func move_toward(pos: Vector2):
	get_parent().position += (pos - get_parent().global_position).normalized() * speed

func _speed_vector(horizontal: bool):
	return _speed_vector_dir(Vector2(1 if horizontal else 0, 0 if horizontal else 1))

func _speed_vector_dir(v: Vector2):
	var s = v * speed * get_process_delta_time()
	return s.rotated(get_parent().rotation) if rotated else s

func rotate_left():
	get_parent().rotation_degrees -= rotation_speed * get_process_delta_time()

func rotate_right():
	get_parent().rotation_degrees += rotation_speed * get_process_delta_time()

func _notification(what):
	if what == NOTIFICATION_PARENTED:
		update_configuration_warnings()

func _get_configuration_warnings():
	if get_parent() is Placeholder and get_parent().get_parent() is CollisionObject2D:
		return ["Do not move the Placeholder, instead move the CollisionObject (Area, Character, Rigid, ...). Otherwise, the collision shape is out-of-sync."]
	return ""
