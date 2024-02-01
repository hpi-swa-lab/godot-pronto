extends Node2D

func get_code():
	return "condition-wall"

func get_stmts():
	return []

func is_condition():
	return true

func check(robot):
	return len(robot.get_node("FrontFree").get_overlapping_bodies()) > 0
