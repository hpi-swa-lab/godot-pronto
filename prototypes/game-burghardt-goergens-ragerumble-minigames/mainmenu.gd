extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_guitar_hero_button_down():
	if get_tree().change_scene_to_file("res://prototypes/game-burghardt-goergens-ragerumble-minigames/GuitarHero/menu.tscn") != OK:
		print ("Error changing to Hero in!")

func _on_shooter_button_down():
	if get_tree().change_scene_to_file("res://prototypes/game-burghardt-goergens-ragerumble-minigames/Shooter/world.tscn") != OK:
		print ("Error changing to Shooter!")

func _on_scream_jump_button_down():
	if get_tree().change_scene_to_file("res://prototypes/game-burghardt-goergens-ragerumble-minigames/Jumper/game-test.tscn") != OK:
		print ("Error changing to Jumper!")
