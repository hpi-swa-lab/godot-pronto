extends Node2D


func get_code():
	return "not"

func get_stmts():
	var areas = self.get_parent().get_overlapping_areas()
	
	areas.sort_custom(func (a: Area2D, b: Area2D): return a.global_position.y < b.global_position.y)
	areas = areas.filter(func(x: Area2D): return x.global_position.y > self.get_parent().global_position.y)
	
	return areas

func is_condition():
	var area = get_node("..")
	if len(area.get_node("Code").get_stmts()) == 0:
		print("No blocks inside container")
		return false
	var condition = area.get_node("Code").get_stmts()[0]
	if not condition.get_node("Code").is_condition():
		print("No conditions inside container")
		return false
	return true

func check(robot):
	var area = get_node("..")
	var condition = area.get_node("Code").get_stmts()[0]
	return not condition.get_node("Code").check(robot)
