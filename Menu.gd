extends Node2D

func _on_play_pressed():
	get_tree().change_scene_to_file("res://prototypes/game-shadows-of-surveillance/levels/game-shadows-of-surveillance.tscn")


func _on_quit_pressed():
	get_tree().quit()
