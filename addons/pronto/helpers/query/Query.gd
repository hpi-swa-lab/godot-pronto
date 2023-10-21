@tool
extends Resource

class_name Query

## The query only filters if it is active.
## If it is not active, every node passes.
@export var active = true

## User-facing name for the query.
## Should be overriden in subclasses.
static func name() -> String:
	return "unnamed query type"

## Checks whether the given node passes this query.
## To change the behavior of this method, override [method Query._does_node_pass].
func does_node_pass(node: Node, query_behavior: QueryBehavior) -> bool:
	return not active or _does_node_pass(node, query_behavior)

## Override this to implement custom query behavior.
func _does_node_pass(node: Node, query_behavior: QueryBehavior) -> bool:
	push_warning("The base Query object does not have any effect (i.e. it filters nothing). Use a specialized Query object instead.")
	return true

## This method is called within [QueryBehavior]'s [method CanvasItem._draw] method.
## Override it and use the draw methods of [CanvasItem] to create an in-editor visualization for the Query.
func draw_query(query_behavior: QueryBehavior) -> void:
	# e.g. query_behavior.draw_circle(...)
	pass

## Returns a control that can be used to edit this query in the inspector.
## Should be overridden in subclasses.
func _query_editor() -> Control:
	var l = Label.new()
	l.text = "exists (If this is not a base Query, you should specialize _query_editor_scene)"
	return l

func query_editor() -> Control:
	var e = _query_editor()
	if e.has_method("set_query"):
		e.set_query(self)
	return e
	
