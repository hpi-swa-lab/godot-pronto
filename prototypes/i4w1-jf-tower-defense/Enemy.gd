extends CharacterBody2D

var max_health: float

@onready var nav_agent := $NavigationAgent2D as NavigationAgent2D
@export var target_location: Node2D
@export var color: Color

@export var range_prop: String = ""

var dead_color: Color
var last_target_position: Vector2
var target: Node2D = null
var attacker: Node2D = null

@export var speed: float
@export var health: float
@export var damage: float

func _ready():
	dead_color = Color(color.r, color.g, color.b, 0.0)
	max_health = health
	if target_location:
		set_move_target(target_location.global_position)
	else:
		set_move_target(self.global_position)

func _physics_process(delta):
	var dir = to_local(nav_agent.get_next_path_position()).normalized()
	velocity = dir * speed
	move_and_slide()
	check_if_target_out_of_dist()
	queue_redraw()
	update_color()
	
func update_color():
	get_node("Placeholder").color = color.lerp(dead_color, 1 - (health / max_health))
	
func _draw() -> void:
	if target != null:
		var target_pos = target.global_position - self.global_position
		var clr = Color.WHITE
		draw_line(Vector2.ZERO, target_pos, clr)
		var head : Vector2 = -target_pos.normalized() * 15
		draw_line(target_pos, target_pos + head.rotated(0.3), clr)
		draw_line(target_pos, target_pos + head.rotated(-0.3), clr)

func reset_target():
	target = null
	resume_moving()
	
func check_if_target_out_of_dist():
	if target == null or self.global_position.distance_to(target.global_position) > G.at(range_prop):
		reset_target()
	
func die():
	queue_free()
	
func set_attacker(node: CharacterBody2D):
	attacker = node
	attacker.target = self
	attacker.stop_moving()
	stop_moving()
	
func attacker_in_range(node: CharacterBody2D):
	if node.target == null:
		set_attacker(node)
	if node.target == self and attacker != null:
		apply_damage(attacker.damage)

func apply_damage(amount: float):
	health = max(0, health - amount)
	if health == 0:
		die()
		
func stop_moving():
	nav_agent.target_position = self.global_position
	
func resume_moving():
	nav_agent.target_position = last_target_position
		
func set_move_target(position: Vector2):
	nav_agent.target_position = position
	last_target_position = position
