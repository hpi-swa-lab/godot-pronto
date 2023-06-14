@tool
extends VBoxContainer

var undo_redo: EditorUndoRedoManager
var _displayed_connections = []
var _check_for_connection_highlight = false

var anchor: Node:
	set(a):
		anchor = a
		# Hi-DPI doesn't size this correctly for unknown reasons
		Utils.fix_minimum_size(%connections)
		Utils.fix_minimum_size(%signals)
		reset_size()

var node: Node:
	set(value):
		node = value
		build_list()

func build_list():
	%connections.clear()
	_displayed_connections = Connection.get_connections(node).duplicate()
	for c in _displayed_connections:
		var added_index = %connections.add_item(c.print(false, false, true), Utils.icon_from_theme("Signals", node))
	
	# connecting to signals for slight performance improvement
	# by avoiding querying mouse position every process call
	if not %connections.is_connected("mouse_entered", _handle_mouse_entered):	
		%connections.mouse_entered.connect(_handle_mouse_entered)
	if not %connections.is_connected("mouse_exited", _handle_mouse_exited):
		%connections.mouse_exited.connect(_handle_mouse_exited)		
	%connections.visible = %connections.item_count > 0

func _handle_mouse_entered():
	_check_for_connection_highlight = true
	
func _handle_mouse_exited():
	_check_for_connection_highlight = false

func _process(delta):
	if anchor:
		var r = Utils.global_rect_of(anchor)
		position = anchor.get_viewport_transform() * Vector2(r.position.x, 2 + r.position.y + r.size.y)

	if %signals.visible:
		if not get_global_rect().has_point(get_viewport().get_mouse_position()):
			%signals.visible = false
			%add.visible = true
			size = Vector2.ZERO
	
	if node and Connection.get_connections(node) != _displayed_connections:
		build_list()

	# there is most likely a way better solution for this
	# feel free to improve it
	if _check_for_connection_highlight and %connections.visible:
		var idx = %connections.get_item_at_position(get_local_mouse_position())
		var name = %connections.get_item_text(idx)
		var conn = Utils.find(Connection.get_connections(node),
			func (c: Connection): return c.print(false, false, true) == name)
		if conn:
			node.highlight_activated(conn)


func _on_add_mouse_entered():
	for c in %signal_list.get_children().slice(2):
		c.queue_free()
	
	if node is Behavior:
		var ui = node.connect_ui()
		if ui != null:
			%signal_list.add_child(ui)
	
	if node.get_script():
		%signal_list.add_child(Utils.build_class_row(node.get_script().resource_path.get_file().split('.')[0], anchor))
		for s in node.get_script().get_script_signal_list():
			%signal_list.add_child(DragSignal.new(s, node, undo_redo))
	for c in Utils.all_classes_of(node):
		%signal_list.add_child(Utils.build_class_row(c, anchor))
		for s in ClassDB.class_get_signal_list(c, true):
			%signal_list.add_child(DragSignal.new(s, node, undo_redo))
	%signals.visible = true
	%add.visible = false

func _on_connections_item_selected(index):
	NodeToNodeConfigurator.open_existing(undo_redo, node, Connection.get_connections(node)[index])

func _on_connections_item_clicked(index, at_position, mouse_button_index):
	if mouse_button_index == MOUSE_BUTTON_RIGHT:
		var m = PopupMenu.new()
		m.add_item("Move to top", 0)
		m.add_item("Delete", 1)
		m.id_pressed.connect(func (id):
			if id == 0:
				Connection.reorder_to_top(node, index, undo_redo, build_list)
			if id == 1:
				Connection.get_connections(node)[index].delete(node, undo_redo))
		add_child(m)
		m.position = Vector2i(global_position + at_position)
		m.popup()
