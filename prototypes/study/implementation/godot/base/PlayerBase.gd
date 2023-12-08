extends Node2D

enum {PLAYER, ENEMY}

@export var player_unit_scene: PackedScene
@export var initial_target: Node2D
@export var spawn_cooldown: float = 1.0
@export var health: float = 100
var max_health
var spawn_timer:Timer = Timer.new()
var type = PLAYER
var last_spawn: int

# Called when the node enters the scene tree for the first time.
func _ready():
	# spawn_timer.timeout.connect(_spawn_unit)
	# spawn_timer.wait_time = spawn_cooldown
	# add_child(spawn_timer)
	# spawn_timer.start()
	max_health = health
	_update_health_display()
	pass

func _update_health_display():
	%PlayerBaseHealthDisplay.text = str(health) + "/" + str(max_health)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_just_pressed("ui_accept"):
		if Time.get_ticks_msec() > last_spawn + (spawn_cooldown*1000):
			_spawn_unit()
			last_spawn = Time.get_ticks_msec()

func _spawn_unit():
	var unit = player_unit_scene.instantiate()
	unit.type = PLAYER
	unit.target = initial_target
	add_child(unit)
	
func damage(amount: int):
	if health > amount:
		health = health - amount
		_update_health_display()
	else:
		print("Player base has been destryoed")
		get_tree().paused = true
