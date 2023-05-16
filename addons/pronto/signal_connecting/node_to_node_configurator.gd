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
	Utils.spawn_popup_from_canvas(from, i)

static func open_new_invoke(undo_redo: EditorUndoRedoManager, from: Node, source_signal: Dictionary, receiver: Node):
	var i = _open(Utils.parent_that(receiver, func (n): return Utils.has_position(n)), undo_redo)
	i.selected_signal = source_signal
	i.from = from
	i.receiver = receiver
	i.set_mode(false, true)
	i.init_empty_scripts()
	Utils.spawn_popup_from_canvas(receiver, i)
	i.default_focus()

static func open_new_expression(undo_redo: EditorUndoRedoManager, from: Node, source_signal: Dictionary):
	var i = _open(Utils.parent_that(from, func (n): return Utils.has_position(n)), undo_redo)
	i.selected_signal = source_signal
	i.from = from
	i.set_mode(true, false)
	i.init_empty_scripts()
	Utils.spawn_popup_from_canvas(from, i)
	i.default_focus()

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

func default_focus():
	await get_tree().process_frame
	if %Expression.visible:
		%Expression.grab_focus()
	else:
		%FunctionName.grab_focus()

func update_argument_names():
	var names = argument_names()
	%Expression.argument_names = names
	for c in %Args.get_children(): c.argument_names = names
	%SignalArgs.text = "({0}) {1}".format([Utils.print_args(selected_signal), "from, to" if %Receiver.visible else "from"])

func _process(delta):
	if anchor and anchor.is_inside_tree():
		position = Utils.popup_position(anchor)
		var offscreen_delta = (position + size - get_parent().size).clamp(Vector2(0, 0), Vector2(1000000, 1000000))
		position -= offscreen_delta
		%FunctionName.anchor = anchor

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
	
	for i in range(%Args.get_child_count()):
		%Args.get_child(i).edit_script = connection.arguments[i] if i <= connection.arguments.size() - 1 else empty_script("null", true)
	
	# FIXME just increment total directly didn't work from the closure?!
	var total = {"total": 0}
	Utils.all_nodes_do(ConnectionsList.get_viewport(),
		func(n):
			total["total"] += Connection.get_connections(n).count(connection))
	%SharedLinksNote.visible = total["total"] > 1
	%SharedLinksCount.text = "This connection is linked to {0} other node{1}.".format([total["total"] - 1, "s" if total["total"] != 2 else ""])

func _on_function_selected(name: String):
	set_mode(name == "<statement(s)>", true)
	
	var method = Utils.find(receiver.get_method_list(), func (m): return m["name"] == name)
	
	for child in %Args.get_children():
		%Args.remove_child(child)
		child.queue_free()
	
	if method == null:
		return
	
	var ExpressionEdit = preload("res://addons/pronto/signal_connecting/expression_edit.tscn")
	for arg in method["args"]:
		var arg_ui = ExpressionEdit.instantiate()
		Utils.fix_minimum_size(arg_ui)
		arg_ui.placeholder_text = "return " + arg["name"]
		arg_ui.edit_script = empty_script("null", true)
		%Args.add_child(arg_ui)
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
			Connection.connect_target(from, selected_signal["name"], from.get_path_to(receiver), invoke,
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
			Connection.connect_expr(from, selected_signal["name"], to_path,
				%Expression.updated_script(from, selected_signal["name"]),
				%Condition.updated_script(from, selected_signal["name"]), undo_redo)
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
