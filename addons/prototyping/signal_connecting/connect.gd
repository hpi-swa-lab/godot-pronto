@tool
extends VBoxContainer

var NodeToNodeConfigurator = load("res://addons/prototyping/signal_connecting/node_to_node_configurator.tscn")

var anchor: Node
var node: Node:
	set(value):
		node = value
		for c in Connection.get_connections(node):
			%connections.add_item(c.signal_name, Utils.icon_from_theme("Signals", node))
		%connections.visible = %connections.item_count > 0

func _process(delta):
	if anchor:
		position = anchor.get_viewport_transform() * anchor.global_position
	
	if %signals.visible:
		if not get_global_rect().has_point(get_viewport().get_mouse_position()):
			%signals.visible = false
			%add.visible = true

func all_classes_of(node: Node):
	var l = []
	var c = node.get_class()
	while c:
		l.append(c)
		c = ClassDB.get_parent_class(c)
	return l

func _on_add_mouse_entered():
	for c in %signal_list.get_children().slice(2):
		c.queue_free()
	
	if node.get_script():
		%signal_list.add_child(build_class_row(node.get_script().resource_path.get_file()))
		for s in node.get_script().get_script_signal_list():
			%signal_list.add_child(DragSignal.new(s, node))
	for c in all_classes_of(node):
		%signal_list.add_child(build_class_row(c))
		for s in ClassDB.class_get_signal_list(c, false):
			%signal_list.add_child(DragSignal.new(s, node))
	%signals.visible = true
	%add.visible = false

func build_class_row(c: StringName):
	var label = Label.new()
	label.text = c
	
	var icon = TextureRect.new()
	icon.stretch_mode = TextureRect.STRETCH_KEEP_CENTERED
	icon.texture = Utils.icon_for_class(c, anchor)
	
	var row = HBoxContainer.new()
	row.add_child(icon)
	row.add_child(label)
	return row

func _on_connections_item_selected(index):
	var popup = NodeToNodeConfigurator.instantiate()
	popup.set_existing_connection(node, Connection.get_connections(node)[index])
	popup.anchor = Utils.parent_that(node, func (n): return Utils.has_position(n))
	Utils.spawn_popup_from_canvas(node, popup)
