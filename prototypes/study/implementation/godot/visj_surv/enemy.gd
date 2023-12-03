extends CharacterBody2D

@export var speed: float = 200
@export var max_speed: float = 400
@export var health = 5
var target: Node2D
var max_health

func _ready():
	max_health = health
	
func _physics_process(delta):
	var direction = (target.global_position - global_position).normalized()
	velocity = velocity.lerp(direction * max_speed, min(1.0, speed * delta))
	move_and_slide()
