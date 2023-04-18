@tool
#thumb("ToolMove")
extends Behavior

@export var speed = 500.0
@export var rotation_speed = 300.0
@export var rotated = false
@export var gravity = 0.0
@export var jump_speed = 800.0
@export var acceleration_curve = Curve.new()
@export var deceleration_curve = Curve.new()

var _acceleration = Vector2.ZERO
var _velocity = Vector2.ZERO

func move_direction(direction: Vector2): _add_acceleration(_speed_vector_dir(direction))
func move_left(): _add_acceleration(-_speed_vector(true))
func move_right(): _add_acceleration(_speed_vector(true))
func move_down(): _add_acceleration(_speed_vector(false))
func move_up(): _add_acceleration(-_speed_vector(false))
func move_toward(pos: Vector2):
	_add_acceleration((pos - get_parent().global_position).normalized() * speed * get_process_delta_time())
func rotate_left(): get_parent().rotation_degrees -= rotation_speed * get_process_delta_time()
func rotate_right(): get_parent().rotation_degrees += rotation_speed * get_process_delta_time()
func jump(): _add_acceleration(Vector2(0, -jump_speed))

func _process(delta):
	if Engine.is_editor_hint():
		return 
	if gravity > 0:
		_add_acceleration(Vector2(0, gravity * get_process_delta_time()))
	
	_velocity *= slowdown()
	_velocity += _acceleration
	_acceleration = Vector2.ZERO
	
	var t = get_parent()
	if t is CharacterBody2D:
		t.velocity = _velocity
		t.move_and_slide()
	else:
		t.position += _velocity

func slowdown():
	var t = get_parent()
	if t is CharacterBody2D and t.is_on_floor():
		return 0.6
	else:
		return 1.0

func _add_acceleration(accel: Vector2):
	_acceleration += accel

func _speed_vector(horizontal: bool):
	return _speed_vector_dir(Vector2(1 if horizontal else 0, 0 if horizontal else 1))

func _speed_vector_dir(v: Vector2):
	var s = v * speed * get_process_delta_time()
	return s.rotated(get_parent().rotation) if rotated else s
