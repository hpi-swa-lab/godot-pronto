@tool
extends PanelContainer
class_name NodeToNodeConfigurator

static func _open(anchor: Node, undo_redo: EditorUndoRedoManager):
	var i = preload("res://addons/pronto/signal_connecting/node_to_node_configurator.tscn").instantiate()
	i.anchor = anchor
	i.undo_redo = undo_redo
	return i

static func open_existing(undo_redo: EditorUndoRedoManager, from: Node, connection: Connection):
	var i = _open(Utils.parent_that(from, func (n): return Utils.has_position(n)), undo_redo)
	i.set_existing_connection(from, connection)
	return i.open(from)

static func open_new_invoke(undo_redo: EditorUndoRedoManager, from: Node, source_signal: Dictionary, receiver: Node):
	var i = _open(Utils.parent_that(receiver, func (n): return Utils.has_position(n)), undo_redo)
	i.selected_signal = source_signal
	i.from = from
	i.receiver = receiver
	i.set_mode(false, true)
	i.init_empty_scripts()
	return i.open(receiver)

static func open_new_expression(undo_redo: EditorUndoRedoManager, from: Node, source_signal: Dictionary):
	var i = _open(Utils.parent_that(from, func (n): return Utils.has_position(n)), undo_redo)
	i.selected_signal = source_signal
	i.from = from
	i.set_mode(true, false)
	i.init_empty_scripts()
	return i.open(from)

func open(receiver: Node):
	# find existing configurator siblings
	for configurator in Utils.popup_parent(receiver).get_children(true):
		if configurator is NodeToNodeConfigurator and configurator.has_same_connection(self):
			configurator.default_focus()
			return configurator
	
	Utils.spawn_popup_from_canvas(receiver, self)
	default_focus()
	return self

func has_same_connection(other: NodeToNodeConfigurator):
	print("has_same_connection", self, " ", other)
	return other.from == from and other.selected_signal == selected_signal

var undo_redo: EditorUndoRedoManager

var anchor: Node:
	set(n):
		anchor = n
		reset_size()
		%FunctionName.anchor = n
var from: Node
var existing_connection = null

var selected_signal: Dictionary:
	set(value):
		selected_signal = value
		%Signal.text = value["name"]
		update_argument_names()

var position_offset = Vector2(0, 0)

var pinned = false:
	set(value):
		print("pinned", value)
		pinned = value
		%Pinned.button_pressed = value

func _input(event):
	if event is InputEventKey and event.keycode == KEY_ESCAPE and event.pressed:
		_on_cancel_pressed()
	if event is InputEventKey and (event.keycode == KEY_ENTER or event.keycode == KEY_KP_ENTER) and event.pressed and event.ctrl_pressed:
		_on_done_pressed()

var receiver: Object:
	set(value):
		receiver = value
		%ReceiverPath.text = "${0} ({1})".format([from.get_path_to(receiver), receiver.name])
		%FunctionName.anchor = anchor
		%FunctionName.node = receiver

func init_empty_scripts():
	%Expression.edit_script = empty_script("", false)
	%Condition.edit_script = empty_script("true", true)

func set_mode(expr: bool, recv: bool):
	%Expression.visible = expr
	%Receiver.visible = recv
	update_argument_names()
	if expr and %Expression.edit_script == null:
		%Expression.edit_script = empty_script("", false)
	mark_changed()

func default_focus():
	await get_tree().process_frame
	if %Expression.visible:
		%Expression.grab_focus()
	else:
		%FunctionName.grab_focus()

func update_argument_names():
	var names = argument_names()
	%Expression.argument_names = names
	%Condition.argument_names = names
	for c in %Args.get_children(): c.argument_names = names
	%SignalArgs.text = "({0}) {1}".format([Utils.print_args(selected_signal), "from, to" if %Receiver.visible else "from"])

func _process(delta):
	if anchor and anchor.is_inside_tree():
		position = Utils.popup_position(anchor) + position_offset
		var offscreen_delta = (position + size - get_parent().size).clamp(Vector2(0, 0), Vector2(1000000, 1000000))
		position -= offscreen_delta
		%FunctionName.anchor = anchor

	if not anchor: return
	var _parent = Utils.popup_parent(anchor)
	if not _parent: return
	var hovered_nodes = _parent.get_children(true).filter(func (n):
		if not (n is NodeToNodeConfigurator): return false
		return n.get_global_rect().has_point(get_viewport().get_mouse_position()))
	var is_hovered = hovered_nodes.size() > 0 and hovered_nodes[-1] == self
	if is_hovered:
		if self.existing_connection:
			from.highlight_activated(self.existing_connection)

func mark_changed(value: bool = true):
	%ChangesNotifier.visible = value

func set_existing_connection(from: Node, connection: Connection):
	self.from = from
	existing_connection = connection
	self.selected_signal = Utils.find(from.get_signal_list(), func (s): return s["name"] == connection.signal_name)
	set_mode(connection.is_expression(), connection.is_target())
	%Condition.edit_script = connection.only_if
	if connection.is_target():
		receiver = from.get_node(connection.to)
		%FunctionName.anchor = anchor
		%FunctionName.text = connection.invoke if not connection.is_expression() else "<statement(s)>"
		_on_function_selected(%FunctionName.text)
	if connection.expression != null:
		%Expression.edit_script = connection.expression
	
	%Receiver.visible = connection.is_target()
	%Expression.visible = connection.is_expression()
	%Enabled.button_pressed = connection.enabled
	
	for i in range(%Args.get_child_count()):
		%Args.get_child(i).edit_script = connection.arguments[i] if i <= connection.arguments.size() - 1 else empty_script("null", true)
	
	# FIXME just increment total directly didn't work from the closure?!
	var total = {"total": 0}
	Utils.all_nodes_do(ConnectionsList.get_viewport(),
		func(n):
			total["total"] += Connection.get_connections(n).count(connection))
	%SharedLinksNote.visible = total["total"] > 1
	%SharedLinksCount.text = "This connection is linked to {0} other node{1}.".format([total["total"] - 1, "s" if total["total"] != 2 else ""])
	mark_changed(false)

func _on_function_selected(name: String):
	set_mode(name == "<statement(s)>", true)
	
	var cond = func (m): return m["name"] == name
	var method = null
	if receiver.get_script() != null:
		method = Utils.find(receiver.get_script().get_script_method_list(), cond)
	if method == null:
		method = Utils.find(receiver.get_method_list(), cond)
	
	for child in %Args.get_children():
		%Args.remove_child(child)
		child.queue_free()
	
	if method == null:
		return
	
	var ExpressionEdit = preload("res://addons/pronto/signal_connecting/expression_edit.tscn")
	
	var arguments = []
	if receiver is Code and name == "execute":
		arguments = Array(receiver.arguments).map(func (argument_name): return {"name": argument_name})
	elif receiver is SceneRoot and name.begins_with("apply"):
		# remove "from" argument so it does not appear in the connection window, 
		# which is automatically set later in Connection.gd::_trigger.
		arguments = method["args"]
		arguments.pop_back()
	else:
		arguments = method["args"]
	
	for arg in arguments:
		var arg_ui = ExpressionEdit.instantiate()
		Utils.fix_minimum_size(arg_ui)
		arg_ui.placeholder_text = "return " + arg["name"]
		if name.begins_with("apply") && arg["type"] == 25:
			if arg["name"] == "filter_func":
				arg_ui.edit_script = empty_script("func(from, node): return true", true)
			else:
				arg_ui.edit_script = empty_script("func(from, node): null", true)
		else:
			arg_ui.edit_script = empty_script("null", true)
		%Args.add_child(arg_ui)
		arg_ui.text_changed.connect(func(): mark_changed())
	update_argument_names()

func empty_script(expr: String, return_value: bool):
	return ConnectionScript.new(argument_names(), return_value, expr)

func argument_names():
	return selected_signal["args"].map(func (a): return a["name"]) + ["from"] + (["to"] if %Receiver.visible else [])

func _on_done_pressed():
	if not %Expression.visible:
		var args = %Args.get_children()
		var invoke = %FunctionName.text
		# TODO check if only_if and args can be parsed
		if invoke.length() == 0: return
		if existing_connection:
			Utils.commit_undoable(undo_redo, "Update condition of connection", existing_connection.only_if,
				{"source_code": %Condition.text}, "reload")
			for i in range(args.size()):
				Utils.commit_undoable(undo_redo, "Update argument {0} of connection".format([i]),
					args[i].edit_script,
					{"source_code": args[i].text}, "reload")
			Utils.commit_undoable(undo_redo,
				"Update connection {0}".format([selected_signal["name"]]),
				existing_connection,
				{"expression": null, "invoke": invoke, "signal_name": %Signal.text, "arguments": args.map(func (a): return a.edit_script)})
		else:
			existing_connection = Connection.connect_target(from, selected_signal["name"], from.get_path_to(receiver), invoke,
				args.map(func (a): return a.updated_script(from, selected_signal["name"])),
				%Condition.updated_script(from, selected_signal["name"]), undo_redo)
	else:
		if existing_connection:
			Utils.commit_undoable(undo_redo, "Update condition of connection", existing_connection.only_if,
				{"source_code": %Condition.text}, "reload")
			if existing_connection.expression != null:
				Utils.commit_undoable(undo_redo, "Update expression of connection", existing_connection.expression,
					{"source_code": %Expression.text}, "reload")
			else:
				Utils.commit_undoable(undo_redo,
					"Set connection expression",
					existing_connection, {"expression": %Expression.updated_script(from, selected_signal["name"])})
			Utils.commit_undoable(undo_redo,
				"Update connection {0}".format([selected_signal["name"]]),
				existing_connection, {"signal_name": %Signal.text})
		else:
			var to_path = from.get_path_to(receiver) if %Receiver.visible else ""
			existing_connection = Connection.connect_expr(from, selected_signal["name"], to_path,
				%Expression.updated_script(from, selected_signal["name"]),
				%Condition.updated_script(from, selected_signal["name"]), undo_redo)

	existing_connection.enabled = %Enabled.button_pressed
	mark_changed(false)
	if not pinned:
		queue_free()

func _on_remove_pressed():
	if existing_connection:
		existing_connection.delete(from, undo_redo)
	queue_free()

func _on_cancel_pressed():
	queue_free()

func _on_make_unique_pressed():
	var duplicate = existing_connection.make_unique(from, undo_redo)
	queue_free()
	open_existing(undo_redo, from, duplicate)

var _drag_start_offset = null

func _on_gui_input(event: InputEvent):
	if event is InputEventMouseButton and event.double_click and event.button_index == MOUSE_BUTTON_LEFT:
		_double_click()
	elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.is_pressed():
			_start_drag(event.global_position)
		else:
			_stop_drag()
	elif event is InputEventMouseMotion and _drag_start_offset != null:
		_drag(event.global_position)

func _double_click():
	pinned = not pinned

func _start_drag(position: Vector2):
	_drag_start_offset = position - position_offset
	self.get_parent().move_child(self, -1)

func _stop_drag():
	_drag_start_offset = null

func _drag(position: Vector2):
	position_offset = position - _drag_start_offset

func _on_pinned_toggled(button_pressed):
	pinned = button_pressed

func _on_enabled_toggled(button_pressed):
	if existing_connection:
		existing_connection.enabled = button_pressed
	else:
		mark_changed()
