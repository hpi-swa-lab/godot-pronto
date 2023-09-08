@tool
extends Query

class_name PredicateQuery

@export var predicate: ConnectionScript = null

static func name():
	return "Custom criterion"

func set_predicate_source(source: String):
	predicate.source_code = source

func _init():
	if predicate == null:
		predicate = ConnectionScript.new()
		predicate.argument_names = ['node']
		predicate.argument_types = ['Node2D']
		predicate.source_code = "node is Node"

func _does_node_pass(node: Node, query_behavior: QueryBehavior):
	return !!(await predicate.run([node]))

func _query_editor() -> Control:
	var e = preload("res://addons/pronto/helpers/query/PredicateQueryEditor.tscn").instantiate()
	e.set_query(self)
	return e
