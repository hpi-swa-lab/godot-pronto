@tool
extends PanelContainer

var DropNode = load("res://addons/prototyping/signal_connecting/drop_node.tscn")

var node: Node:
	set(value):
		node = value
		for child in all_children_without_position(node):
			var row = DropNode.instantiate()
			row.node = node
			%list.add_child(row)

func all_children_without_position(root: Node, list: Array[Node] = [root]):
	for c in root.get_children():
		if not Utils.has_position(c):
			list.append(c)
			all_children_without_position(c, list)
	return list
