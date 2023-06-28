extends CharacterBody2D


@onready var nav_agent := $NavigationAgent2D as NavigationAgent2D

@export var speed = 80

func _ready():
	nav_agent.path_desired_distance = 4.0

func _physics_process(delta):
	queue_redraw()
	if(!nav_agent.is_target_reached()):
		var dir = to_local(nav_agent.get_next_path_position()).normalized()
		velocity = dir * speed
		move_and_slide()

func set_move_target(position: Vector2):
	nav_agent.target_position = position
