@tool
extends EditorDebuggerPlugin
class_name ConnectionDebug

var debug_lists: Dictionary
var editor_interface: EditorInterface

func _init(editor_interface: EditorInterface):
	self.editor_interface = editor_interface

func find_connections_by_path(path: String):
	var list = Utils.all_nodes_that(ConnectionsList.get_viewport(),
		func(n): return Connection.get_connections(n).any(func(c): return c.resource_path.split("::")[1] == path))
	return list.map(func (node): return [node, Utils.find(Connection.get_connections(node), func(c): return c.resource_path.split("::")[1] == path)])

func _has_capture(prefix):
	return prefix == "pronto"

func _capture(message, data, session_id):
	if message == "pronto:connection_activated":
		var path = data[0]
		var list = Utils.remove_duplicates_by(find_connections_by_path(path.split("::")[1]), func (c): return c[1].resource_path.split("::")[1])
		for c in list:
			var from = c[0]
			var connection = c[1]
			add_to_list(session_id, from, connection)
			if from is Behavior:
				from.connection_activated(connection)
		return true
	if message == "pronto:state_put":
		var state = editor_interface.get_edited_scene_root().get_parent().get_node(str(data[0]).substr(6))
		assert(state is State)
		state._report_game_value(data[1], data[2])
		return true

func add_to_list(session_id, from, connection):
	var list: ItemList = debug_lists.get(session_id)
	if list == null:
		return
	var at_bottom = list.get_v_scroll_bar().value >= (list.get_v_scroll_bar().max_value - list.size.y - 12)
	list.add_item(
		"{0}:{1} -> {2}:{3}".format([from, connection.signal_name, connection.to, connection.invoke])
		if connection.is_target()
		else "{0}:{1} ↺ {2}".format([from, connection.signal_name, connection.expression]))
	if at_bottom:
		await list.get_tree().process_frame
		list.get_v_scroll_bar().value = list.get_v_scroll_bar().max_value + 100

func _setup_session(session_id):
	var list = ItemList.new()
	list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	
	# TODO modify interface/editor/unfocused_low_processor_mode_sleep_usec
	# while the game is running
	var session = get_session(session_id)
	session.started.connect(list.clear)
	# session.stopped.connect(func (): pass)
	
	var clear = Button.new()
	clear.text = "Clear"
	clear.pressed.connect(list.clear)
	
	var row = HBoxContainer.new()
	row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.name = "Pronto Connections"
	row.add_child(list)
	row.add_child(clear)
	
	session.add_session_tab(row)
	debug_lists[session_id] = list
