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

static func between(x: float, min: float, max: float):
	return x >= min and x <= max

static func has_position(node: Node):
	return node is Node3D or node is Control or node is Node2D

static func spawn_popup_from_canvas(reference: Node, popup: Node):
	reference.get_viewport().get_parent().get_parent().get_parent().get_parent().get_parent().add_child(popup, false, Node.INTERNAL_MODE_BACK)
	popup.position = popup_position(parent_that(reference, func (c): return Utils.has_position(c)))

static func popup_position(anchor: Node):
	return anchor.get_viewport_transform() * anchor.global_position

static func icon_from_theme(name: StringName, reference: Node):
	if Engine.is_editor_hint():
		return reference.get_viewport().get_parent().get_parent().get_theme_icon(name, &"EditorIcons")
	else:
		return null

static func icon_for_node(node: Node, reference: Node):
	if node.get_script():
		var name = node.get_script().resource_path.get_file().split('.')[0]
		var behaviors = G.at("_pronto_behaviors")
		if name in behaviors:
			return icon_from_theme(behaviors[name], reference)
	return icon_for_class(node.get_class(), reference)

static func icon_for_class(name: StringName, reference: Node):
	return icon_from_theme(name, reference)

static func all_classes_of(node: Node):
	var l = []
	var c = node.get_class()
	while c:
		l.append(c)
		c = ClassDB.get_parent_class(c)
	return l

static func build_class_row(c: StringName, ref: Node):
	var label = Label.new()
	label.text = c
	
	var icon = TextureRect.new()
	icon.stretch_mode = TextureRect.STRETCH_KEEP_CENTERED
	var behaviors = G.at("_pronto_behaviors")
	icon.texture = Utils.icon_from_theme(behaviors[c], ref) if c  in behaviors else Utils.icon_for_class(c, ref)
	
	var row = HBoxContainer.new()
	row.add_child(icon)
	row.add_child(label)
	return row

static func commit_undoable(undo_redo: EditorUndoRedoManager, title: String, object: Object, props: Dictionary):
	undo_redo.create_action(title)
	for prop in props:
		undo_redo.add_undo_property(object, prop, object.get(prop))
		undo_redo.add_do_property(object, prop, props[prop])
	undo_redo.commit_action()

static func random_point_on_screen():
	var size = Engine.get_main_loop().root.size
	return Vector2(randf_range(0, size.x), randf_range(0, size.y))

static func mouse_position():
	return Engine.get_main_loop().root.get_mouse_position()

static func ellipsize(s: String, max: int):
	if s.length() <= max:
		return s
	return s.substr(0, s.length() - 3) + "..."

static func global_rect_of(node: Node):
	if "size" in node: return Rect2(node.global_position, node.size)
	if "shape" in node and node.shape:
		var s = node.shape.get_rect().size
		return Rect2(node.global_position - s / -2, s)
	return Rect2(node.global_position, Vector2.ZERO)
