extends Area2D

var respawn_pos: Vector2
# Called when the node enters the scene tree for the first time.
func _ready():
	respawn_pos = get_parent().find_child("SpawnPoint", true, false).position
	self.body_entered.connect(_reset_player)

func _reset_player(other):
	if other is CharacterBody2D:
		get_parent().get_parent().find_child("Player", true, false).position = respawn_pos

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
