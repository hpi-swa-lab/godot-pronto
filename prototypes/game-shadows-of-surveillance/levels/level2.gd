extends Node2D

var player
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	player = get_node("Player2")
	if player:
		if player.global_position.y > 1000:
			player.queue_free()
			get_tree().change_scene_to_file("res://Restart.tscn")
