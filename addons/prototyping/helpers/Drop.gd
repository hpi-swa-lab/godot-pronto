extends Panel
class_name PDrop

var container: VBoxContainer
var node: Node

func _init(node: Node):
	self.node = node
	
	var anchor = parentThat(node, is_visible_node)
	node.get_viewport().get_parent().get_parent().get_parent().get_parent().get_parent().add_child(self, false, Node.INTERNAL_MODE_BACK)
	position = anchor.get_viewport_transform() * anchor.global_position
	
	container = VBoxContainer.new()
	
	var c = MarginContainer.new()
	c.add_theme_constant_override("margin_top", 6)
	c.add_theme_constant_override("margin_left", 6)
	c.add_theme_constant_override("margin_bottom", 6)
	c.add_theme_constant_override("margin_right", 6)
	
	var scroll = ScrollContainer.new()
	scroll.set_anchors_preset(Control.PRESET_FULL_RECT)
	scroll.add_child(c)
	c.add_child(container)
	add_child(scroll)
	
	build(node, false)
	
	# mouse_entered.connect(func (): build(node, true))
	# mouse_exited.connect(func (): build(node, false))

func build(node: Node, full: bool):
	for child in container.get_children():
		child.queue_free()
	
	container.add_theme_constant_override("separation", -10)
	for child in all_invisible_children(node):
		var row = HBoxContainer.new()
		row.add_theme_constant_override("separation", -4)
		var name_label = Label.new()
		name_label.text = child.name
		var icon = node.get_viewport().get_parent().get_parent().get_theme_icon(child.name, &"EditorIcons")
		if icon:
			var tex = TextureRect.new()
			tex.texture = icon
			tex.stretch_mode = TextureRect.STRETCH_KEEP_CENTERED
			row.add_child(tex)
		row.add_child(name_label)
		container.add_child(row)
		if full:
			for method in get_methods_for(child):
				container.add_child(PMethod.new(method, child))
	
	custom_minimum_size = Vector2(150, 300) if full else Vector2(150, 60)

func get_methods_for(node: Node) -> Array[Dictionary]:
	if node.get_script():
		return node.get_script().get_script_method_list()
	else:
		return ClassDB.class_get_method_list(node.get_class(), true)

func parentThat(node: Node, cond: Callable):
	if cond.call(node):
		return node
	return parentThat(node.get_parent(), cond)

func is_visible_node(node: Node):
	return node is Node3D or node is Control or node is Node2D

func all_invisible_children(root: Node, list: Array[Node] = [root]):
	for c in root.get_children():
		if not c is Control and not c is Node2D:
			list.append(c)
			all_invisible_children(c, list)
	return list


# connect popup

func _can_drop_data(at_position, data):
	print("can")
	return "type" in data and data["type"] == "P_CONNECT_SIGNAL"

func _drop_data(at_position, data):
	print(data)
	show_connect_popup(data)
	# var source_signal = data["signal"]
	# data["source"].connect(source_signal["name"], func(): Callable(target, target_method["name"]).call(), CONNECT_PERSIST)

func show_connect_popup(data):
	var list := Tree.new()
	list.hide_root = true
	list.set_anchors_preset(Control.PRESET_FULL_RECT)
	list.size_flags_vertical = Control.SIZE_EXPAND_FILL
	
	var filter := LineEdit.new()
	filter.placeholder_text = "Filter methods ..."
	
	var root := list.create_item()
	for method in get_methods_for(node):
		var child := list.create_item(root)
		child.set_metadata(0, method)
		child.set_text(0, method["name"])
	
	filter.text_changed.connect(func (text: String):
		var first: TreeItem = null
		for item in root.get_children():
			item.visible = text.is_empty() or text in item.get_text(0)
			if not first and item.visible: first = item
		if first: first.select(0))
	
	var column := VBoxContainer.new()
	column.set_anchors_preset(Control.PRESET_FULL_RECT)
	column.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	column.add_child(filter)
	column.add_child(list)
	
	var method_column := VBoxContainer.new()
	method_column.set_anchors_preset(Control.PRESET_FULL_RECT)
	method_column.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var unbound_args := SpinBox.new()
	method_column.add_child(unbound_args)
	
	var row := HBoxContainer.new()
	row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.set_anchors_preset(Control.PRESET_FULL_RECT)
	row.add_child(column)
	row.add_child(method_column)
	
	var popup := Popup.new()
	popup.exclusive = true
	popup.wrap_controls = true
	popup.popup_window = false
	popup.borderless = false
	popup.unresizable = false
	popup.add_child(row)
	
	var n = node
	var do_connect := func():
		popup.close_requested.emit()
		var s = data["signal"]["name"]
		var method = list.get_selected().get_metadata(0)["name"]
		var invoke = Callable(n, method)
		
		var expressions = method_column.get_children().slice(1)
		var signal_args = data["signal"]["args"]
		var unbind = max(unbound_args.value, signal_args.size() - expressions.size())
		if unbound_args.value > 0: invoke.unbind(unbound_args.value)
		invoke.bindv(expressions.slice(signal_args.size() - unbound_args.value).map(func (s: LineEdit):
			var e = Expression.new()
			e.parse(s.text)
			return e.execute()))
		data["source"].connect(s, invoke, CONNECT_PERSIST)
	
	filter.text_submitted.connect(func (s): do_connect.call())
	
	list.item_selected.connect(func ():
		var method := list.get_selected().get_metadata(0)
		for child in method_column.get_children().slice(1):
			child.queue_free()
		var index = 0
		var signal_args = data["signal"]["args"]
		for arg in method["args"]:
			var arg_expr = LineEdit.new()
			arg_expr.text_submitted.connect(func (s): do_connect.call())
			arg_expr.placeholder_text = "(required) " + arg["name"] if index > signal_args.size() - 1 else signal_args[index]["name"] + " => " + arg["name"]
			method_column.add_child(arg_expr)
			index += 1
		unbound_args.min_value = max(signal_args.size() - method["args"].size(), 0)
		unbound_args.value = unbound_args.min_value
		unbound_args.max_value = data["signal"]["args"].size()
		unbound_args.value_changed.emit(0.0))
	
	unbound_args.value_changed.connect(func (unbind: float):
		var index = 0
		var bind = data["signal"]["args"].size() - unbind
		for child in method_column.get_children().slice(1):
			child.editable = index >= bind
			index += 1)
	
	node.get_viewport().get_parent().get_parent().add_child(popup)
	popup.size = Vector2(500, 500)
	popup.popup()
	popup.child_controls_changed()
	
	filter.grab_focus()

func print_signal(data: Dictionary):
	return data["name"] + "(" + data["args"].map(func (arg): return arg["name"]).join(", ") + ")"
