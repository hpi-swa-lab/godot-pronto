@tool
#thumb("JoyButton")
extends Behavior
class_name PlatformerControllerBehavior

@export_category("Gameplay")
## The speed with which the character jumps.
@export var jump_velocity: float = 400
## The speed with which the character moves sideways.
@export var horizontal_velocity: float = 400
## The amount of time after falling off a platform where the character can still jump, in seconds.
@export_range(0.0, 1.0) var coyote_time = 0.1
## The amount of time a jump input will trigger a jump if the character is not touching the floor, in seconds.
@export_range(0.0, 1.0) var jump_buffer = 0.1

@export var can_always_jump = false

@export_category("Physics")
@export var gravity_paused: bool = false:
	get: return gravity_paused
	set(value): gravity_paused = value

@export_category("Debug")
## If enabled, the parent leaves a trail of recent positions.
@export var show_trail: bool = false

@onready var _parent: CharacterBody2D = get_parent()

var _last_on_floor = -10000
@onready var _last_floor_height = _parent.position.y
var _last_jump_input = -10000

var _last_positions_max = 30
var _last_positions = []

signal collided(last_collision: KinematicCollision2D)

func _enter_tree():
	if not get_parent() is CharacterBody2D:
		push_error("PlatformerController must be a child of a CharacterBody2D")

func _update_jump():
	var now = Time.get_ticks_msec()
	var gravity = PhysicsServer2D.body_get_direct_state(_parent).total_gravity.normalized()
	
	if (_parent.is_on_floor() and gravity.angle_to(Vector2.DOWN) < PI) or (_parent.is_on_ceiling() and gravity.angle_to(Vector2.UP) < PI):
		_last_on_floor = now
		_last_floor_height = _parent.position.y
		
	if Input.is_action_just_pressed("ui_accept"):
		_last_jump_input = now

func _can_jump():
	var now = Time.get_ticks_msec()
	var input = _last_jump_input > now - 1000 * jump_buffer
	var floored = _last_on_floor > now - 1000 * coyote_time
	return input and (can_always_jump or floored)

func _reset_jump():
	_last_jump_input = -10000
	_last_on_floor = -10000

func _draw():
	super._draw()
	if !show_trail:
		return
	
	draw_set_transform(-position - _parent.position)
	for pos in _last_positions:
		draw_circle(pos, 3, Color.RED)

func _physics_process(delta):
	if Engine.is_editor_hint():
		return
	
	var gravity = PhysicsServer2D.body_get_direct_state(_parent).total_gravity
	if gravity_paused:
		gravity = Vector2.ZERO
	
	# vertical
	_update_jump()
	if _can_jump():
		_reset_jump()
		if _parent.position.y > _last_floor_height:
			_parent.position.y = _last_floor_height
		_parent.velocity.y = -jump_velocity * gravity.normalized().y
	else:
		_parent.velocity.y += gravity.y * delta
	
	# move
	var did_collide = _parent.move_and_slide()
	
	if did_collide:
		collided.emit(_parent.get_last_slide_collision())
	
	# trail
	_last_positions.append(_parent.position)
	if _last_positions.size() > _last_positions_max:
		_last_positions.pop_front()
	
	queue_redraw()

func lines():
	return super.lines() + [Lines.DashedLine.new(self, get_parent(), func (f): return "controls", "controls")]
