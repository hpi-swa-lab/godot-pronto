extends Node2D

func _on_Start_Button_button_down():
	if get_tree().change_scene_to_file("res://prototypes/game-burghardt-goergens-ragerumble-minigames/Jumper/game-test.tscn") != OK:
		print ("Error changing scene to Jumper Gameplay")

func _unhandled_input(event):
	if Input.is_action_just_pressed("quit"):
		get_tree().change_scene_to_file("res://prototypes/game-burghardt-goergens-ragerumble-minigames/game-burghardt-goergens-ragerumble-minigames.tscn")