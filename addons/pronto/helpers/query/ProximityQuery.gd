@tool
extends Query

class_name ProximityQuery

@export var radius: float = 50

static func name():
	return "Proximity"

func _does_node_pass(node: Node, query_behavior: QueryBehavior):
	if not node is Control and not node is Node2D:
		return
	
	var distance = query_behavior.global_position.distance_to(node.global_position)
	return distance <= radius

func draw_query(query_behavior: QueryBehavior):
	query_behavior.draw_circle(Vector2.ZERO, radius, Color(0, 0, 1, 0.5))

func _query_editor() -> Control:
	var e = preload("res://addons/pronto/helpers/query/ProximityQueryEditor.tscn").instantiate()
	e.set_radius(radius)
	return e
