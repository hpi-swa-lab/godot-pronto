extends Node
class_name Utils

static func with(o, do: Callable):
	return do.call(o)

static func parent_that(node: Node, cond: Callable):
	if node == null:
		return null
	if cond.call(node):
		return node
	return parent_that(node.get_parent(), cond)

static func all_nodes_do(node: Node, do: Callable, include_internal = false):
	for c in node.get_children(include_internal):
		all_nodes_do(c, do, include_internal)
	do.call(node)

static func first_node_that(node: Node, cond: Callable):
	for c in node.get_children():
		if cond.call(c):
			return c
		var ret = first_node_that(c, cond)
		if ret != null:
			return ret
	return null

static func all_nodes_that(node: Node, cond: Callable):
	var list = []
	all_nodes_do(node, func (c): if cond.call(c): list.append(c))
	return list

static func all_nodes(node: Node, include_internal = false):
	var list = []
	all_nodes_do(node, func (c): list.append(c), include_internal)
	return list

static func print_signal(data: Dictionary):
	return data["name"] + "(" + print_args(data) + ")"

static func print_args(data: Dictionary):
	return ", ".join(data["args"].map(func (arg): return arg["name"]))

static func sum(list: Array):
	return list.reduce(func (accum, i): return accum + i, 0)

static func max(list: Array):
	return list.reduce(func (accum, i): return max(accum, i), list[0])

static func remove_duplicates(list: Array):
	var out = []
	for i in list:
		if out.find(i) < 0:
			out.append(i)
	return out

static func remove_duplicates_by(list: Array, criterium: Callable):
	var seen = {}
	var out = []
	for i in list:
		var key = criterium.call(i)
		if not key in seen:
			seen[key] = true
			out.append(i)
	return out

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

static func group_by(list: Array, criterium: Callable):
	var groups = {}
	for i in list:
		var key = criterium.call(i)
		if not key in groups: groups[key] = [i]
		else: groups[key].append(i)
	return groups

static func between(x: float, min: float, max: float):
	return x >= min and x <= max

static func has_position(node: Node):
	return 'global_position' in node

static func find_position(node: Node):
	var root = closest_parent_with_position(node)
	return root.global_position if root else null

static func closest_parent_with_position(node: Node) -> Node:
	return Utils.closest_parent_that(node, Callable(Utils, 'has_position'))

static func closest_parent_that(node: Node, cond: Callable) -> Node:
	while node != null:
		if cond.call(node):
			return node
		node = node.get_parent()
	return null

static func spawn_popup_from_canvas(reference: Node, popup: Node):
	popup_parent(reference).add_child(popup, false, Node.INTERNAL_MODE_BACK)
	popup.position = popup_position(parent_that(reference, func (c): return Utils.has_position(c)))

static func popup_parent(reference: Node):
	var viewport = reference.get_viewport()
	if not viewport:
		return null
	return viewport.get_parent().get_parent().get_parent().get_parent().get_parent()

static func popup_position(anchor: Node):
	return anchor.get_viewport_transform() * anchor.global_position

static func icon_from_theme(name: StringName, reference: Node):
	if Engine.is_editor_hint():
		var ref = reference if reference.get_viewport().get_parent() == null else reference.get_viewport().get_parent().get_parent()
		return ref.get_theme_icon(name, &"EditorIcons")
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

static func commit_undoable(undo_redo: EditorUndoRedoManager, title: String, object: Object, props: Dictionary, action = null):
	if not props.keys().any(func (prop): return props[prop] != object.get(prop)):
		return
	undo_redo.create_action(title)
	for prop in props:
		undo_redo.add_undo_property(object, prop, object.get(prop))
		undo_redo.add_do_property(object, prop, props[prop])
	if action != null:
		undo_redo.add_do_method(object, action)
		undo_redo.add_undo_method(object, action)
	undo_redo.commit_action()

static func get_game_size():
	return Vector2(ProjectSettings.get_setting("display/window/size/viewport_width"), ProjectSettings.get_setting("display/window/size/viewport_height"))

static func random_point_on_screen():
	return Vector2(randf(), randf()) * get_game_size()

static func mouse_position():
	return Engine.get_main_loop().root.get_mouse_position()

static func ellipsize(s: String, max: int = 16):
	if s.length() <= max or max < 0:
		return s
	return s.substr(0, max - 3) + "..."

static func global_size_of_yourself(node: Node):
	if "size" in node: return Rect2(node.global_position, node.size)
	return Rect2(node.global_position, Vector2.ZERO)

static func global_rect_of(node: Node):
	node = Utils.closest_parent_with_position(node)
	if node is Placeholder or node is HealthBar: return Rect2(node.global_position - node.size / 2, node.size)
	if "size" in node: return Rect2(node.global_position, node.size)
	if "shape" in node and node.shape:
		var s = node.shape.get_rect().size
		return Rect2(node.global_position - s / -2, s)
	return Rect2(node.global_position, Vector2.ZERO)

static func fix_minimum_size(n: Control):
	if G.at("_pronto_editor_plugin") == null:
		return
	n.custom_minimum_size *= G.at("_pronto_editor_plugin").get_editor_interface().get_editor_scale()

static func log(s):
	var a = FileAccess.open("res://log", FileAccess.READ_WRITE if FileAccess.file_exists("res://log") else FileAccess.WRITE_READ)
	a.seek_end()
	a.store_string(str(s) + "\n")
	a.close()

static func get_specific_class_name(node: Node):
	# See https://github.com/godotengine/godot/issues/21789.
#	var name := node.to_string()
#	if name.match("?*:?*"):
#		return name.split(":")[0]
	return node.get_class()

const TYPE_NAMES = ['nil', 'bool', 'int', 'float', 'String', 'Vector2', 'Vector2I', 'Rect2', 'Rect2i', 'Vector3', 'Vector3i', 'Transform2D', 'Vector4', 'Vector4i', 'Plane', 'Quaternion', 'AABB', 'Basis', 'Transform3D', 'Projection', 'Color', 'StringName', 'NodePath', 'RID', 'Object', 'Callable', 'Signal', 'Dictionary', 'Array', 'PackedByteArray', 'PackedInt32Array', 'PackedInt64Array', 'PackedFloat32Array', 'PackedFloat64Array', 'PackedStringArray', 'PackedVector2Array', 'PackedVector3Array', 'PackedColorArray']
static func get_type_name_from_arg(arg: Dictionary) -> String:
	if arg["type"] == 24: return arg["class_name"]
	else: return TYPE_NAMES[arg["type"]]
