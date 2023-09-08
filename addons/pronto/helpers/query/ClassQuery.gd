@tool
extends Query

class_name ClassQuery

@export var name_of_class: StringName = &"CanvasItem"

static func name():
	return "Class"

func _does_node_pass(node: Node, query_behavior: QueryBehavior):
	return node.is_class(name_of_class)

func _query_editor() -> Control:
	var e = preload("res://addons/pronto/helpers/query/ClassQueryEditor.tscn").instantiate()
	e.set_query(self)
	return e
