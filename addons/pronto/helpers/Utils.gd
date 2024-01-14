extends Node
class_name Utils

static func as_code_string(arg) -> String:
	match typeof(arg):
		TYPE_NIL: return ""
		TYPE_BOOL: return str(arg)
		TYPE_INT: return str(arg)
		TYPE_FLOAT: return str(arg)
		TYPE_STRING: return '"' + arg + '"'
		TYPE_VECTOR2:
			if str(arg) != "(inf, inf)":
				return "Vector2" + str(arg)
			else:
				return "Vector2(INF,INF)"
		TYPE_RECT2: return "Rect2" + str(arg)
		TYPE_VECTOR3: return "Vector3" + str(arg)
		TYPE_TRANSFORM2D: return "Transform2D" + str(arg)
		TYPE_PLANE: return "Plane" + str(arg)
		TYPE_QUATERNION: return "Quat" + str(arg)
		TYPE_AABB: return "AABB" + str(arg)
		TYPE_BASIS: return "Basis" + str(arg)
		TYPE_TRANSFORM3D: return "Transform3D" + str(arg)
		TYPE_COLOR: return "Color" + str(arg)
		TYPE_NODE_PATH: return str(arg)
		TYPE_RID: return str(arg)
		TYPE_OBJECT: return str(arg)
		TYPE_ARRAY: return str(arg)
		_:
			push_warning("Trying to stringify unknown type: " + str(typeof(arg)))
	return str(arg)

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

static func remove_children(node: Node):
	for child in node.get_children():
		node.remove_child(child)

static func print_signal(data: Dictionary):
	return data["name"] + "(" + print_args(data) + ")"

static func print_args(data: Dictionary):
	return ", ".join(data["args"].map(func (arg): return arg["name"]))

static func sum(list: Array):
	return list.reduce(func (accum, i): return accum + i, 0)

static func max(list: Array):
	return list.reduce(func (accum, i): return max(accum, i), list[0])

static func random_sample(list: Array, n: int, weight_func: Callable) -> Array:
	var sample = []
	var weights = {}
	for ea in list:
		weights[ea] = weight_func.call(ea)
	for i in n:
		var total = sum(weights.values())
		if total <= 0:
			break
		var random = randf() * total
		var accum = 0
		for ea in list:
			accum += weights[ea]
			if accum >= random:
				sample.append(ea)
				weights[ea] = 0
				break
	return sample

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
	
static func get_custom_class_name(node: Node):
	var script = node.get_script()
	var regex = RegEx.new()
	regex.compile("class_name (?<class_name>\\w+)")
	var result = regex.search(script.get_source_code())
	if result:
		return result.get_string("class_name")
		
static func get_script_properties(node: Node, filter_underscore: bool = true):
	var script = node.get_script()
	if not script: return
	var properties =  script.get_script_property_list()
	if filter_underscore:
		var new_props = []
		for prop in properties:
			if not prop["name"].begins_with("_"):
				new_props.push_back(prop)
		return new_props
	return properties	

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

# undo_redo: EditorUndoRedoManager (cant annotate or it will crash during export)
static func commit_undoable(undo_redo, title: String, object: Object, props: Dictionary, action = null):
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

static func get_game_size() -> Vector2:
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

static func global_rect_of(node: Node, depth: int = 0, excluded: Array = []) -> Rect2:
	if not node is CanvasItem:
		return Rect2(0, 0, 0, 0)
	
	var rect = Rect2(node.global_position, Vector2.ZERO)
	node = Utils.closest_parent_with_position(node)
	if node is PlaceholderBehavior or node is HealthBarBehavior:
		rect = Rect2(node.global_position - node.size / 2, node.size)
	elif "size" in node:
		rect = Rect2(node.global_position, node.size)
	elif "shape" in node and node.shape:
		var s = node.shape.get_rect().size
		rect = Rect2(node.global_position - s / -2, s)
	elif "get_rect" in node:
		rect = node.global_transform * node.get_rect()

	if depth == 0:
		return rect
	
	return node.get_children() \
		.filter(func(child): return child not in excluded and child is Node2D) \
		.map(func(child): return global_rect_of(child, depth - 1, excluded)) \
		.reduce(func(a, b): return a.merge(b), rect)

static func all_node_classes():
	var classes = ClassDB.get_inheriters_from_class('Node')
	# could include these, but no usable for Node.is_class() anyway
	# classes.append_array(ProjectSettings.get_global_class_list().map(func (c): return c['class']))
	classes.sort()
	return classes

static func all_used_groups(from, root = null, include_internal = false):
	if root == null:
		if Engine.is_editor_hint():
			root = G.at('_pronto_editor_plugin').get_tree().get_edited_scene_root()
		else:
			if not from.is_inside_tree(): return []
			root = from.get_tree().current_scene
	var groups := []
	all_nodes_do(root, func (node):
		if node != root:
			groups.append_array(node.get_groups()))
	groups = remove_duplicates(groups)
	if not include_internal:
		groups = groups.filter(func (group): return not group.begins_with('_'))
	# cannot sort StringNames (https://github.com/godotengine/godot/issues/58878)
	#groups.sort()
	groups.sort_custom(func (a, b): return String(a) < String(b))
	return groups

static func fix_minimum_size(n: Control):
	if G.at("_pronto_editor_plugin") == null:
		return
	n.custom_minimum_size *= hidpi_scale()

static func hidpi_scale():
	return G.at("_pronto_editor_plugin").get_editor_interface().get_editor_scale()

static func log(s):
	var a = FileAccess.open("res://log", FileAccess.READ_WRITE if FileAccess.file_exists("res://log") else FileAccess.WRITE_READ)
	a.seek_end()
	a.store_string(str(s) + "\n")
	a.close()

static func get_specific_class_name(node: Node):
	# See https://github.com/godotengine/godot/issues/21789.
	if node == null:
		return null
	# var name := node.to_string()
	# if name.match("?*:?*"):
	# 	return name.split(":")[0]
	return node.get_class()

const TYPE_NAMES = ['nil', 'bool', 'int', 'float', 'String', 'Vector2', 'Vector2I', 'Rect2', 'Rect2i', 'Vector3', 'Vector3i', 'Transform2D', 'Vector4', 'Vector4i', 'Plane', 'Quaternion', 'AABB', 'Basis', 'Transform3D', 'Projection', 'Color', 'StringName', 'NodePath', 'RID', 'Object', 'Callable', 'Signal', 'Dictionary', 'Array', 'PackedByteArray', 'PackedInt32Array', 'PackedInt64Array', 'PackedFloat32Array', 'PackedFloat64Array', 'PackedStringArray', 'PackedVector2Array', 'PackedVector3Array', 'PackedColorArray']
static func get_type_name_from_arg(arg: Dictionary) -> String:
	if arg["type"] == 24: return arg["class_name"]
	else: return TYPE_NAMES[arg["type"]]


## If the passed object is a Behavior, return it.
## Otherwise, we create a Behavior as a hidden child that will now
## perform tasks such as drawing connections for that non-Behavior node.
static func get_behavior(object):
	if not is_instance_valid(object) or not object is Node: return null
	if object is Behavior: return object
	for child in object.get_children(true):
		if child is Behavior and child.hidden_child: return child
	var b = Behavior.new()
	b.hidden_child = true
	object.add_child(b, false, INTERNAL_MODE_FRONT)
	return b

static func count_lines(string):
	return string.split('\n').size()
