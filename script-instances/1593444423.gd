extends U

func run(other, from, to):
	# GENERATED, DO NOT EDIT
	var facing = Vector2(0,-1).rotated(from.get_parent().rotation)
	var relative_position = (to.get_parent().position - from.get_parent().position).normalized()
	return other.get_node("Move").add_velocity(relative_position * from.collision_power)
	
