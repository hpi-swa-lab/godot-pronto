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

static func all_nodes(node: Node):
	var list = []
	all_nodes_do(node, func (c): list.append(c))
	return list

static func print_signal(data: Dictionary):
	return data["name"] + "(" + ", ".join(data["args"].map(func (arg): return arg["name"])) + ")"

static func sum(list: Array):
	return list.reduce(func (accum, i): return accum + i, 0)

static func max(list: Array):
	return list.reduce(func (accum, i): return max(accum, i), list[0])

static func find(list: Array, cond: Callable):
	for i in list:
		if cond.call(i):
			return i
	return null

static func find_index(list: Array, cond: Callable):
	for i in range(list.size()):
		if cond.call(list[i]):
			return i
	return -1

static func all_nodes_that(root: Node, cond: Callable, list: Array[Node] = []):
	if cond.call(root):
		list.append(root)
	for c in root.get_children():
		all_nodes_that(c, cond, list)
	return list

static func has_position(node: Node):
	return node is Node3D or node is Control or node is Node2D

static func spawn_popup_from_canvas(reference: Node, popup: Node):
	reference.get_viewport().get_parent().get_parent().get_parent().get_parent().get_parent().add_child(popup, false, Node.INTERNAL_MODE_BACK)
	popup.position = popup_position(parent_that(reference, func (c): return Utils.has_position(c)))

static func popup_position(anchor: Node):
	return anchor.get_viewport_transform() * anchor.global_position

static func icon_from_theme(name: StringName, reference: Node):
	return reference.get_viewport().get_parent().get_parent().get_theme_icon(name, &"EditorIcons")

static func icon_for_class(name: StringName, reference: Node):
	return icon_from_theme(name, reference)
