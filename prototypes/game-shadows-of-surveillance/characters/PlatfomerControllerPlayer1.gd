@tool
#thumb("JoyButton")
extends Behavior
class_name PlatformerControllerPlayer1

@export_category("Gameplay")
## Defines the available controls
enum Controls {
	WASD = 0, ## A - D, Jump: Space
	Arrow_Keys = 1, ## Arrow keys
	IJKL = 2  ## J - L, Jump: I
}

## Determines which controls (keys) are used. 
## Which keys that are is defined in [member PlatformControllerBehavior.key_map]
##
## See [enum PlatformControllerBehavior.Controls] for possible values
@export var controls: Controls = Controls.WASD
## The speed with which the character jumps.
@export var jump_velocity: float = 400:
	set(v):
		jump_velocity = v
## The speed with which the character moves sideways.
@export var horizontal_velocity: float = 400:
	set(v):
		horizontal_velocity = v
## The amount of time after falling off a platform where the character can still jump, in seconds.
@export_range(0.0, 1.0) var coyote_time = 0.1
## The amount of time a jump input will trigger a jump if the character is not touching the floor, in seconds.
@export_range(0.0, 1.0) var jump_buffer = 0.1

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

# Make sure that these keys are identical to the comments from the enum "Controls" above when changing them.
var key_map = [{
	"function": Input.is_physical_key_pressed,
	"left": KEY_A,
	"right": KEY_D,
	"jump": [KEY_SPACE, KEY_W]
},
{
	"function": Input.is_action_pressed,
	"left": "ui_left",
	"right": "ui_right",
	"jump": "ui_up"
},
{
	"function": Input.is_physical_key_pressed,
	"left": KEY_J,
	"right": KEY_L,
	"jump": KEY_I
}]

func _enter_tree():
	if not get_parent() is CharacterBody2D:
		push_error("PlatformerController must be a child of a CharacterBody2D")

func _update_jump():
	var now = Time.get_ticks_msec()
	
	if _parent.is_on_floor():
		_last_on_floor = now
		_last_floor_height = _parent.position.y
		
	if _is_key_pressed("jump"):
		_last_jump_input = now

func _can_jump():
	var now = Time.get_ticks_msec()
	var input = _last_jump_input > now - 1000 * jump_buffer
	var floored = _last_on_floor > now - 1000 * coyote_time
	return input and floored

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

func _is_key_pressed(direction):
	var keys = key_map[controls]
	if (typeof(keys[direction]) == TYPE_ARRAY):
		return keys[direction].any(func(key): return keys["function"].call(key))
	else:
		return keys["function"].call(keys[direction])

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
		_parent.velocity.y = -jump_velocity
	else:
		_parent.velocity.y += gravity.y * delta
	
	# horizontal
	var input_direction_x = 0
	if _is_key_pressed("left"):
		input_direction_x += -1
	if _is_key_pressed("right"):
		input_direction_x += 1
	_parent.velocity.x = input_direction_x * horizontal_velocity
	_parent.velocity.x += gravity.x * delta
	
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
