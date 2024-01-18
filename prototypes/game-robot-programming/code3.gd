extends Node2D


func get_code():
	return "condition-random"

func get_stmts():
	return []

func is_condition():
	return true

func check(_robot):
	return randi_range(0, 10) < 5
