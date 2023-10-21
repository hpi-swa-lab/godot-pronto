@tool
extends Query

class_name GroupQuery

@export var group: String = ""

static func name():
	return "Group"

func _does_node_pass(node: Node, query_behavior: QueryBehavior):
	return node.is_in_group(group)

func _query_editor() -> Control:
	var e = preload("res://addons/pronto/helpers/query/GroupQueryEditor.tscn").instantiate()
	return e
