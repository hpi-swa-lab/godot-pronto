extends Node2D


func get_code():
	return "main"

func get_stmts():
	var areas = self.get_parent().get_overlapping_areas()
	
	areas.sort_custom(func (a: Area2D, b: Area2D): return a.position.y < b.position.y)
	
	areas = areas.filter(func(x: Area2D): return x.position.y > self.get_parent().position.y)
	
	return areas

func is_condition():
	return false
