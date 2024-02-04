extends Node2D

func _on_Start_Button_button_down():
	if get_tree().change_scene_to_file("res://prototypes/game-burghardt-goergens-ragerumble-minigames/GuitarHero/game-prompt7-burghardt-goergens.tscn") != OK:
		print ("Error changing scene to Guitar Hero Gameplay")
