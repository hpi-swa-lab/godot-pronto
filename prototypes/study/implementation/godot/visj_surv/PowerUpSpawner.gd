extends Node2D

@export var spawn_cooldown: float = 5
@export var powerup_scene: PackedScene
var spawn_timer = Timer.new()
var rng = RandomNumberGenerator.new()
enum {COOLDOWN, HEALTH}

func _ready():
	spawn_timer.timeout.connect(_spawn_powerup)
	spawn_timer.wait_time = spawn_cooldown
	add_child(spawn_timer)
	spawn_timer.start()
	
func _spawn_powerup():
	var powerup = powerup_scene.instantiate()
	powerup.position = Utils.random_point_on_screen()
	powerup.type = COOLDOWN if rng.randi() % 2 == 0 else HEALTH
	add_child(powerup)
