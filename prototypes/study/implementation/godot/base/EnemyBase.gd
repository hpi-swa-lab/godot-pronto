extends Node2D

enum {PLAYER, ENEMY}

@export var enemy_unit_scene: PackedScene
@export var initial_target: Node2D
@export var spawn_cooldown: float = 1.0
@export var health: float = 100
var max_health
var spawn_timer:Timer = Timer.new()
var type = ENEMY

# Called when the node enters the scene tree for the first time.
func _ready():
	spawn_timer.timeout.connect(_spawn_timer_timeout)
	spawn_timer.wait_time = spawn_cooldown
	add_child(spawn_timer)
	spawn_timer.start()
	max_health = health
	_update_health_display()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _spawn_timer_timeout():
	var unit = enemy_unit_scene.instantiate()
	unit.type = ENEMY
	unit.target = initial_target
	add_child(unit)
	
func _update_health_display():
	%EnemyBaseHealthDisplay.text = str(health) + "/" + str(max_health)
	
func damage(amount: int):
	if health > amount:
		health = health - amount
		_update_health_display()
	else:
		print("Enemy base has been destroyed, you WIN!")
		get_tree().paused = true
