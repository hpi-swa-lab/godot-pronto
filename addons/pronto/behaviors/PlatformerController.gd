@tool
#thumb("JoyButton")
extends Behavior

@export_category("Gameplay")
## The speed with which the character jumps.
@export var jump_velocity: float = 400
## The speed with which the character moves sideways.
@export var horizontal_velocity: float = 400
## The amount of time after falling off a platform where the character can still jump, in seconds.
@export_range(0.0, 1.0) var coyote_time = 0.1
## The amount of time a jump input will trigger a jump if the character is not touching the floor, in seconds.
@export_range(0.0, 1.0) var jump_buffer = 0.1

@export_category("Debug")
## If enabled, the parent leaves a trail of recent positions.
@export var show_trail: bool = false

@onready var gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity")

@onready var _parent: CharacterBody2D = get_parent()

var _last_on_floor = -10000
@onready var _last_floor_height = _parent.position.y
var _last_jump_input = -10000
var _last_time_jump_allow = -10000

var _last_positions_max = 30
var _last_positions = []

signal collided(last_collision: KinematicCollision2D)

func _enter_tree():
	if not get_parent() is CharacterBody2D:
		push_error("PlatformerController must be a child of a CharacterBody2D")

func _update_jump():
	var now = Time.get_ticks_msec()
	
	if _parent.is_on_floor():
		_last_on_floor = now
		_last_floor_height = _parent.position.y
		
	if Input.is_action_just_pressed("ui_accept"):
		_last_jump_input = now

func _can_jump():
		var now = Time.get_ticks_msec()
		var input = _last_jump_input > now - 1000 * jump_buffer
		if(G.at("playerUnderWater")):
			return input and _last_jump_input > 1000 and (now - _last_time_jump_allow) > G.at("JumpTimeOutUnderWater")
		else :
			var floored = _last_on_floor > now - 1000 * coyote_time
			return input and floored

func _underwater_jump_condition():
	if G.at("playerUnderWater"):
		return G.at("CanPlayerSwimUp") == 1
	else:
		return true	

func _reset_jump():
	_last_jump_input = -10000
	_last_on_floor = -10000
	
func reset_jump():
	#_last_jump_input = 	Time.get_ticks_msec()
	_last_on_floor = Time.get_ticks_msec()

func _draw():
	if !show_trail:
		return
	
	draw_set_transform(-position - _parent.position)
	for pos in _last_positions:
		draw_circle(pos, 3, Color.RED)

func _physics_process(delta):
	if Engine.is_editor_hint():
		return
	
	# vertical - climbing
	if G.at("playerFreeY"):
		# we set gravity as not to worry about later calculations while in Area2D
		gravity = 0
		if Input.is_action_pressed("ui_up"):
			_parent.velocity.y = -(float(G.at("ClimbingSpeed")))
		elif Input.is_action_pressed("ui_down"):
			_parent.velocity.y = (float(G.at("ClimbingSpeed")))
		else:
			_parent.velocity.y = 0
				
	
	# vertical
	_update_jump()
	if _can_jump():
		_reset_jump()
		_last_time_jump_allow = Time.get_ticks_msec()
		#print("jump")
		# Why is this necessary?
		#if _parent.position.y > _last_floor_height:
		#	_parent.position.y = _last_floor_height
		_parent.velocity.y = -jump_velocity
	else:
		#print("no jump")
		if G.at("playerUnderWater"):
			#_parent.velocity.y += min(gravity * delta , float(G.at("WaterMaxVelocity")))
			#_parent.velocity.y += gravity * delta * G.at("VerticalSlowdown")
			if(_parent.velocity.y < 0):
				_parent.velocity.y += gravity * delta * G.at("VerticalSpeedupUpwards")
			else:
				_parent.velocity.y += min(gravity * delta, float(G.at("WaterMaxVelocity")))
		else:
			_parent.velocity.y += gravity * delta

	
	# horizontal
	
	if(G.at("playerUnderWater")):
		_parent.velocity.x = Input.get_axis("ui_left", "ui_right") * horizontal_velocity * G.at("HorizontalSlowdown")
	else:
		_parent.velocity.x = Input.get_axis("ui_left", "ui_right") * horizontal_velocity
	
	
	
	# move
	var did_collide = _parent.move_and_slide()
	
	if did_collide:
		collided.emit(_parent.get_last_slide_collision())
	
	# trail
	_last_positions.append(_parent.position)
	if _last_positions.size() > _last_positions_max:
		_last_positions.pop_front()
	
	queue_redraw()
