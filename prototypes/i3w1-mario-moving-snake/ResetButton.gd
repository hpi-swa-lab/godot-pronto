extends Button


func _on_pressed():
	print("Reset")
	get_tree().reload_current_scene()
