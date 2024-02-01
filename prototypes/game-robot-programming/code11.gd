extends Node2D

func get_code():
	return "condition-enemy-directly"

func get_stmts():
	return []

func is_condition():
	return true

func check(robot):
	var bodies = robot.get_node("FrontFree").get_overlapping_bodies()
	return len(bodies) > 0 and bodies[0].is_in_group("Robot")
