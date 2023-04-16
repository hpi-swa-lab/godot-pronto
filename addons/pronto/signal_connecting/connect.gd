@tool
extends VBoxContainer

var NodeToNodeConfigurator = load("res://addons/pronto/signal_connecting/node_to_node_configurator.tscn")

var anchor: Node:
	set(a):
		anchor = a
		size = Vector2.ZERO

var node: Node:
	set(value):
		node = value
		for c in Connection.get_connections(node):
			%connections.add_item(c.signal_name, Utils.icon_from_theme("Signals", node))
		%connections.visible = %connections.item_count > 0

func _process(delta):
	if anchor:
		var r = Utils.global_rect_of(anchor)
		position = anchor.get_viewport_transform() * Vector2(r.position.x, 2 + r.position.y + r.size.y)

	if %signals.visible:
		if not get_global_rect().has_point(get_viewport().get_mouse_position()):
			%signals.visible = false
			%add.visible = true
			size = Vector2.ZERO

func _on_add_mouse_entered():
	for c in %signal_list.get_children().slice(2):
		c.queue_free()
	
	if node.get_script():
		%signal_list.add_child(Utils.build_class_row(node.get_script().resource_path.get_file().split('.')[0], anchor))
		for s in node.get_script().get_script_signal_list():
			%signal_list.add_child(DragSignal.new(s, node))
	for c in Utils.all_classes_of(node):
		%signal_list.add_child(Utils.build_class_row(c, anchor))
		for s in ClassDB.class_get_signal_list(c, true):
			%signal_list.add_child(DragSignal.new(s, node))
	%signals.visible = true
	%add.visible = false

func _on_connections_item_selected(index):
	var popup = NodeToNodeConfigurator.instantiate()
	popup.set_existing_connection(node, Connection.get_connections(node)[index])
	popup.anchor = Utils.parent_that(node, func (n): return Utils.has_position(n))
	Utils.spawn_popup_from_canvas(node, popup)
	popup.default_focus()
