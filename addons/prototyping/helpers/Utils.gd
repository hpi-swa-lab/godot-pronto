extends Node
class_name Utils

static func parent_that(node: Node, cond: Callable):
	if cond.call(node):
		return node
	return parent_that(node.get_parent(), cond)

static func all_nodes_do(node: Node, do: Callable):
	for c in node.get_children():
		all_nodes_do(c, do)
	do.call(node)
