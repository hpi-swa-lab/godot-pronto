extends Node2D


func get_code():
	return "condition-facing"

func get_stmts():
	return []

func is_condition():
	return true

func check(robot):
	return robot.orientation == int($"../TextEdit".text)
