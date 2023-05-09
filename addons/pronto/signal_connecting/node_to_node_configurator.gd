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
	i.default_focus()

static func open_new_invoke(undo_redo: EditorUndoRedoManager, from: Node, source_signal: Dictionary, receiver: Node):
	var i = _open(Utils.parent_that(receiver, func (n): return Utils.has_position(n)), undo_redo)
	i.selected_signal = source_signal
	i.from = from
	i.receiver = receiver
	i.set_mode(false, true)
	Utils.spawn_popup_from_canvas(receiver, i)
	i.default_focus()

static func open_new_expression(undo_redo: EditorUndoRedoManager, from: Node, source_signal: Dictionary):
	var i = _open(Utils.parent_that(from, func (n): return Utils.has_position(n)), undo_redo)
	i.selected_signal = source_signal
	i.from = from
	i.set_mode(true, false)
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
		%SignalArgs.text = "({0})".format([Utils.print_args(value)])
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

func set_mode(expr: bool, recv: bool):
	%Expression.visible = expr
	%Expression.text = ''
	%Receiver.visible = recv
	update_argument_names()
	%SignalArgs.text +=  " from" if not recv else " from, to"

func default_focus():
	await get_tree().process_frame
	if %Expression.visible:
		%Expression.grab_focus()
	else:
		%FunctionName.grab_focus()

func update_argument_names():
	var names = selected_signal["args"].map(func (a): return a["name"]) + ["from"] + (["to"] if %Receiver.visible else [])
	%Expression.argument_names = names
	for c in %Args.get_children(): c.argument_names = names

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
	%Condition.text = connection.only_if
	if connection.is_target():
		receiver = from.get_node(connection.to)
		%FunctionName.anchor = anchor
		%FunctionName.text = connection.invoke if not connection.is_expression() else "<statement(s)>"
		_on_function_selected(%FunctionName.text)
	%Expression.text = connection.expression
	
	%Receiver.visible = connection.is_target()
	%Expression.visible = connection.is_expression()
	
	for i in range(%Args.get_child_count()):
		%Args.get_child(i).text = connection.arguments[i] if i <= connection.arguments.size() - 1 else ""
	
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
		arg_ui.text = "return " + arg["name"]
		%Args.add_child(arg_ui)
	update_argument_names()

func _on_done_pressed():
	if not %Expression.visible:
		var args = %Args.get_children().map(func (c): return c.text)
		var invoke = %FunctionName.text
		if invoke.length() == 0 or args.any(func (a): return a.length() == 0): return
		if existing_connection:
			Utils.commit_undoable(undo_redo,
				"Update connection {0}".format([selected_signal["name"]]),
				existing_connection,
				{"arguments": args, "expression": "", "invoke": invoke, "only_if": %Condition.text, "signal_name": %Signal.text})
		else:
			Connection.connect_target(from, selected_signal["name"], from.get_path_to(receiver), invoke, args, %Condition.text, undo_redo)
	else:
		if existing_connection:
			Utils.commit_undoable(undo_redo,
				"Update connection {0}".format([selected_signal["name"]]),
				existing_connection,
				{"arguments": [], "expression": %Expression.text, "invoke": "", "only_if": %Condition.text, "signal_name": %Signal.text})
		else:
			var to_path = from.get_path_to(receiver) if %Receiver.visible else ""
			Connection.connect_expr(from, selected_signal["name"], to_path, %Expression.text, %Condition.text, undo_redo)
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
