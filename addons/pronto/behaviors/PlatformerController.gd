@tool
#thumb("JoyButton")
extends Behavior

@export var jump_velocity: float = 400
@export var horizontal_velocity: float = 400

@onready var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
@onready var parent: CharacterBody2D = get_parent()

signal collided(last_collision: KinematicCollision2D)

func _enter_tree():
	if not get_parent() is CharacterBody2D:
		push_error("PlatformerController must be a child of a CharacterBody2D")

func _physics_process(delta):
	if Engine.is_editor_hint():
		return
	
	if parent.is_on_floor() and Input.is_action_just_pressed("ui_accept"):
		parent.velocity.y -= jump_velocity
	else:
		parent.velocity.y += gravity * delta
	
	parent.velocity.x = Input.get_axis("ui_left", "ui_right") * horizontal_velocity
	
	var did_collide = parent.move_and_slide()
	
	if did_collide:
		collided.emit(parent.get_last_slide_collision())
