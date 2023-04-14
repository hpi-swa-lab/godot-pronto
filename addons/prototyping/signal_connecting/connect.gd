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

func _draw():
	if not node:
		return
	
	for connection in node.get_meta("pronto_connections", []):
		var other = node.get_node_or_null(connection.to)
		if not other:
			continue
		var begin = Vector2.ZERO
		var end = other.global_position - node.global_position
		draw_line(begin, end, Color.RED, 5)


func _process(delta):
	queue_redraw() # TODO: don't always redraw
	
	if anchor:
		var offset = Vector2.ZERO
		if "size" in anchor: offset = Vector2(0, anchor.size.y)
		if "shape" in anchor and anchor.shape: offset = anchor.shape.get_rect().size.y / 2 * Vector2(-1, 1)
		position = anchor.get_viewport_transform() * (anchor.global_position + offset + Vector2(0, 2))

	if %signals.visible:
		if not get_global_rect().has_point(get_viewport().get_mouse_position()):
			%signals.visible = false
			%add.visible = true

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
