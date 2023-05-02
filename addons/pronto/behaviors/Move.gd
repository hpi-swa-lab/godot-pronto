@tool
#thumb("ToolMove")
extends Behavior

signal touched_floor(velocity: float)

@export_category("Ground")
@export var max_velocity = 500.0
@export var acceleration = 100.0
@export var friction = 20.0

@export_category("Air")
@export var gravity = 0.0
@export var friction_air = 0.0
@export var acceleration_air = 0.0

@export_category("Rotation")
@export var rotated = false
@export var rotation_speed = 0.0
@export var rotate_velocity = true

var velocity = Vector2.ZERO
var _did_accelerate = false
var _was_on_floor = false

func is_on_floor():
	if get_parent() is CharacterBody2D:
		return true
		return get_parent().is_on_floor()
	return false if gravity > 0.0 else true

func add_velocity(velocity: Vector2):
	_did_accelerate = true
	self.velocity += velocity

func set_velocity_y(num: float):
	_did_accelerate = true
	self.velocity.y = num

func set_velocity_x(num: float):
	_did_accelerate = true
	self.velocity.x = num

func _physics_process(delta):
	if Engine.is_editor_hint():
		return
	# on the floor, we only want to apply friction is we did not accelerate this frame
	if not _did_accelerate and is_on_floor():
		velocity = velocity.lerp(Vector2.ZERO, min(1.0, friction * delta))
	# in the air, we always want to apply friction
	if not is_on_floor():
		velocity.x = lerp(velocity.x, 0.0, min(1.0, friction_air * delta))
	
	if gravity > 0.0:
		velocity.y += gravity * delta
	
	var _current_velocity = velocity
	if get_parent() is CharacterBody2D:
		var char := get_parent() as CharacterBody2D
		char.velocity = velocity
		char.move_and_slide()
		velocity = char.velocity
	elif get_parent() is PhysicsBody2D:
		get_parent().move_and_collide(velocity * delta)
	else:
		get_parent().position += velocity * delta
	_did_accelerate = false
	
	if _was_on_floor != is_on_floor():
		_was_on_floor = is_on_floor()
		if is_on_floor():
			touched_floor.emit(_current_velocity)

func move_direction(direction: Vector2):
	var _accel = acceleration if is_on_floor() else acceleration_air
	_did_accelerate = true
	if rotated:
		direction = direction.rotated(get_parent().rotation)
	velocity = velocity.lerp(direction * max_velocity, min(1.0, _accel * get_process_delta_time()))

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
	var s = rotation_speed * get_process_delta_time()
	get_parent().rotation_degrees -= s
	if rotate_velocity:
		velocity = velocity.rotated(-deg_to_rad(s))

func rotate_right():
	var s = rotation_speed * get_process_delta_time()
	get_parent().rotation_degrees += s
	if rotate_velocity:
		velocity = velocity.rotated(deg_to_rad(s))

func _notification(what):
	if what == NOTIFICATION_PARENTED:
		update_configuration_warnings()

func _get_configuration_warnings():
	if get_parent() is Placeholder and get_parent().get_parent() is CollisionObject2D:
		return ["Do not move the Placeholder, instead move the CollisionObject (Area, Character, Rigid, ...). Otherwise, the collision shape is out-of-sync."]
	return ""
