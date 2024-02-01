extends Node2D


func get_code():
	return "while"

func get_stmts():
	var areas = self.get_parent().get_overlapping_areas()
	
	areas.sort_custom(func (a: Area2D, b: Area2D): return a.global_position.y < b.global_position.y)
	
	areas = areas.filter(func(x: Area2D): return x.global_position.y > self.get_parent().global_position.y)
	
	return areas

func is_condition():
	return false
