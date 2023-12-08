extends CharacterBody2D

enum {PLAYER, ENEMY}
enum {TRAVEL, ATTACK}

var target: Node2D
@export var speed: float = 200
@export var max_speed: float = 400
var type
var target_base: Node2D
var state = TRAVEL
@export var health = 5
var max_health
var attack_timer:Timer = Timer.new()
@export var attack_range: Area2D
@export var attack_dmg: float = 1
@export var attack_cooldown: float = 1

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

func _ready():
	target_base = target
	attack_range.body_entered.connect(_handle_body_entered)
	attack_range.area_entered.connect(_handle_area_entered)
	max_health = health
	attack_timer.timeout.connect(_attack)
	attack_timer.wait_time = attack_cooldown
	add_child(attack_timer)
	_update_health_display()
	
func _update_health_display():
	%HealthDisplay.text = str(health) + "/" + str(max_health)

func _physics_process(delta):
	if is_instance_valid(target):
		if state == TRAVEL:
			var direction = (target.global_position - global_position).normalized()
			velocity = velocity.lerp(direction * max_speed, min(1.0, speed * delta))
			move_and_slide()
	else:
		state = TRAVEL
		target = target_base

func _handle_body_entered(other):
	if other is CharacterBody2D and other.type != self.type:
		if state == TRAVEL:
			target = other
			state = ATTACK
			attack_timer.start()

func _handle_area_entered(other):
	if other.name.contains("Base") and other.get_parent().type != self.type:
		state = ATTACK
		target = target_base
		attack_timer.start()
		
func damage(amount: int):
	if health > amount:
		health = health - amount
		_update_health_display()
	else:
		queue_free()

func _attack():
	if is_instance_valid(target):
		target.damage(attack_dmg)
	else:
		attack_timer.stop()
		state = TRAVEL
		target = target_base	
		
