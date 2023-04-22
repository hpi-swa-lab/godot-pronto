@tool
extends EditorDebuggerPlugin
class_name ConnectionDebug

var debug_lists: Dictionary

func find_connection_by_path(path: String):
	var node = Utils.first_node_that(ConnectionsList.get_viewport(),
		func(n): return Connection.get_connections(n).any(func(c): return c.resource_path == path))
	if node == null:
		# print("Connection {0} not found locally. Created at runtime?".format([path]))
		return null
	return [node, Utils.find(Connection.get_connections(node), func(c): return c.resource_path == path)]

func _has_capture(prefix):
	return prefix == "pronto"

func _capture(message, data, session_id):
	if message == "pronto:connection_activated":
		var path = data[0]
		var c = find_connection_by_path(path)
		if c == null:
			return true
		var from = c[0]
		var connection = c[1]
		add_to_list(session_id, from, connection)
		if from is Behavior:
			from.connection_activated(connection)
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
