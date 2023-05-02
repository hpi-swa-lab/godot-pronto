extends U

func run(other, from, to):
	# GENERATED, DO NOT EDIT
	return other.get_node("Move").add_velocity((to.get_parent().position - from.get_parent().position).normalized() * from.collision_power)
