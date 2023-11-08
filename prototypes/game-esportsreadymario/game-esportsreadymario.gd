extends Node


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var viewport_1 := %SubViewport1
	var viewport_2 := %SubViewport2
	var player_1 := viewport_1.get_node("jumpnrun_template/Player1")
	var player_2 := viewport_1.get_node("jumpnrun_template/Player2")
	viewport_2.world_2d = viewport_1.world_2d
	player_2.get_node("Camera2D").custom_viewport = viewport_2
	player_2.get_node("Camera2D").make_current()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
