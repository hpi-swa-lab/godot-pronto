@tool
#thumb("ToolMove")
extends Behavior

signal touched_floor

@export_category("Ground")
@export var max_velocity = 500.0
@export var rotation_speed = 300.0
@export var rotated = false
@export var acceleration = 100.0
@export var friction = 20.0

@export_category("Air")
@export var gravity = 0.0
@export var friction_air = 0.0
@export var acceleration_air = 0.0

var _velocity = Vector2.ZERO
var _did_accelerate = false
var _was_on_floor = false

func is_on_floor():
	if get_parent() is CharacterBody2D:
		return get_parent().is_on_floor()
	return false if gravity > 0.0 else true

func add_velocity(velocity: Vector2):
	_did_accelerate = true
	_velocity += velocity

func _physics_process(delta):
	if Engine.is_editor_hint():
		return
	var _friction = friction if is_on_floor() else friction_air
	if not _did_accelerate:
		_velocity = _velocity.lerp(Vector2.ZERO, min(1.0, _friction * delta))
	
	if gravity > 0.0:
		_velocity.y += gravity * delta
	
	if get_parent() is CharacterBody2D:
		var char := get_parent() as CharacterBody2D
		char.velocity = _velocity
		char.move_and_slide()
		_velocity = char.velocity
	elif get_parent() is PhysicsBody2D:
		get_parent().move_and_collide(_velocity * delta)
	else:
		get_parent().position += _velocity * delta
	_did_accelerate = false
	
	if _was_on_floor != is_on_floor():
		_was_on_floor = is_on_floor()
		if is_on_floor():
			touched_floor.emit()

func move_direction(direction: Vector2):
	var _accel = acceleration if is_on_floor() else acceleration_air
	_did_accelerate = true
	if rotated:
		direction = direction.rotated(get_parent().rotation)
	_velocity = Vector2(
		lerp(_velocity.x, direction.x * max_velocity, min(1.0, abs(direction.x) * _accel * get_process_delta_time())),
		lerp(_velocity.y, direction.y * max_velocity, min(1.0, abs(direction.y) * _accel * get_process_delta_time())),
	)

func move_left():
	move_direction(Vector2.LEFT)

func move_right():
	move_direction(Vector2.RIGHT)

func move_down():
	move_direction(Vector2.DOWN)

func move_up():
	move_direction(Vector2.UP)

func move_toward(pos: Vector2):
	move_direction((pos - get_parent().global_position).normalized())

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
