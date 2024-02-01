extends Node2D

func get_code():
	return "condition-enemy-vision"

func get_stmts():
	return []

func is_condition():
	return true

func check(robot):
	var bodies = robot.get_node("Vision").get_overlapping_bodies()
	for body in bodies:
		if body.is_in_group("Robot"):
			return true
	return false
