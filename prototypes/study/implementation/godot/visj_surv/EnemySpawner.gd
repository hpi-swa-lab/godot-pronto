extends Node2D

@export var enemy_scene: PackedScene
@export var spawn_cooldown: float = 1
var spawn_timer = Timer.new()
var rng = RandomNumberGenerator.new()

# Called when the node enters the scene tree for the first time.
func _ready():
	spawn_timer.timeout.connect(_spawn_enemy)
	spawn_timer.wait_time = spawn_cooldown
	add_child(spawn_timer)
	spawn_timer.start()

func _spawn_enemy():
	# determine random pos
	var enemy = enemy_scene.instantiate()
	enemy.position = _determine_random_spawn_outside_screen()
	enemy.target = %Player
	add_child(enemy)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _determine_random_spawn_outside_screen():
	var width = Utils.get_game_size().x
	var height = Utils.get_game_size().y
	
	if rng.randi() % 2 == 0:
		# top or bottom
		var x = rng.randi_range(0, width)
		var y = rng.randi_range(-50, 0) if rng.randi() % 2 == 0 else rng.randi_range(height, height + 50)
		return Vector2(x, y)
	else:
		# left or right
		var x = rng.randi_range(-50, 0) if rng.randi() % 2 == 0 else rng.randi_range(width, width + 50)
		var y = rng.randi_range(0, height)
		return Vector2(x, y)
