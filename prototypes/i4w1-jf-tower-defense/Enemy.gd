extends CharacterBody2D

@export var speed = 50
@export var health = 100
@export var demage = 10
@onready var nav_agent := $NavigationAgent2D as NavigationAgent2D
@export var target: Node2D

func _physics_process(delta):
	var dir = to_local(nav_agent.get_next_path_position()).normalized()
	velocity = dir * speed
	move_and_slide()
	
func _ready():
	if target:
		set_move_target(target.global_position)
	
func set_move_target(position: Vector2):
	nav_agent.target_position = position
	
func damage(amount: float):
	print("take damage")
	health = max(0, health - amount)
	if health == 0:
		queue_free()
