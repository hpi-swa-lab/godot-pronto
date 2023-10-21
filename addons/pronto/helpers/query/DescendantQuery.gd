@tool
extends Query

class_name DescendantQuery

@export var path: NodePath = "."

static func name():
	return "Descendant"

func _does_node_pass(node: Node, query_behavior: QueryBehavior):
	return query_behavior.get_node(path).is_ancestor_of(node)

func _query_editor() -> Control:
	var e = preload("res://addons/pronto/helpers/query/DescendantQueryEditor.tscn").instantiate()
	return e
