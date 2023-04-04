extends Node

signal left
signal right

func _process(delta):
	if Input.is_action_pressed("ui_left"):
		emit_signal("left")
	if Input.is_action_pressed("ui_right"):
		emit_signal("right")
