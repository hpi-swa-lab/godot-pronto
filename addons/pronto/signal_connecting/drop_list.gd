@tool
extends PanelContainer

var DropNode = load("res://addons/pronto/signal_connecting/drop_node.tscn")

var nodes: Array:
	set(value):
		nodes = value
		for child in nodes:
			add(child)
			for c in all_children_without_position(child):
				add(c)

func add(node: Node):
	var row = DropNode.instantiate()
	row.node = node
	%list.add_child(row)

func all_children_without_position(root: Node, list: Array[Node] = []):
	for c in root.get_children():
		if not Utils.has_position(c):
			list.append(c)
			all_children_without_position(c, list)
	return list
