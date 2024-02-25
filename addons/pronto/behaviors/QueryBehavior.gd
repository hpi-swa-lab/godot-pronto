@tool
#thumb("Search")
extends Behavior
class_name QueryBehavior
## Searches for nodes in the scene and emits signals for results.
## Properties allow to filter, sort, and limit results.
## All properties can be overridden through the [code]parameters[/code] argument of the [code]query()[/code] method.
## Can be used for tasks such as destroying all enemies in a certain radius, infecting a random player, or finding the nearest health pack.

@export var queries: Array[Query] = []

## Emitted for each node found, ordered according to the priority strategy.
## [param node] The node that was found.)
signal found(node)

## Emitted once all nodes have been found.
## [param nodes] The nodes that were found.
signal found_all(nodes)

## Emitted if no node was found.
signal found_none()

## Initiate a query. Returns 
## [param]
func query(emit_results = true):
	var additional_queries = []
	var nodes = Utils.all_nodes_that(get_tree().get_root(), func(node: Node):
		if node == self:
			return
		var does_node_pass = func(query):
			return query.does_node_pass(node, self)
		return queries.all(does_node_pass) and additional_queries.all(does_node_pass))
	
	found_all.emit(nodes)
	if nodes.size() == 0:
		found_none.emit()
	else:
		for node in nodes:
			found.emit(node)
