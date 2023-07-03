extends Area2D

@export var current_field = Vector2(0, 0);
@export var quadrant_size: float = 60
@export var zero_position: Vector2 = Vector2(359, 90)
@export_enum("Player1", "Player2") var player = 0
	
func _ready():
	update_position()
	
func cross_attack():
	var spwner_name = "CrossSpawner1" if player == 0 else "CrossSpawner2"
	var spawner = get_parent().get_node(spwner_name)
	for i in range(0,8,1):
		spawner.spawn_at(_get_position(Vector2(i, current_field.y)))
		if i != current_field.y:
			spawner.spawn_at(_get_position(Vector2(current_field.x, i)))
	
func move_up():
	if current_field.y > 0:
		current_field.y -= 1
		update_position()

func move_down():
	if current_field.y < 7:
		current_field.y += 1
		update_position()

func move_left():
	if current_field.x > 0:
		current_field.x -= 1
		update_position()

func move_right():
	if current_field.x < 7:
		current_field.x += 1
		update_position()
		
func _get_position(field):
	return zero_position + field * quadrant_size
		
func update_position():
	self.global_position = _get_position(current_field)
