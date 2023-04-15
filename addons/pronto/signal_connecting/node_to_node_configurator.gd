@tool
extends PanelContainer

var anchor: Node:
	set(n):
		anchor = n
		size = Vector2.ZERO
		%FunctionName.anchor = n
var from: Node
var existing_connection = null

func _input(event):
	if event is InputEventKey and event.keycode == KEY_ESCAPE and event.pressed:
		_on_cancel_pressed()
	if (event is InputEventKey and event.keycode == KEY_ENTER and event.pressed
		and not %FunctionName.has_focus()
		and (not %Expression.visible or event.ctrl_pressed)):
		_on_done_pressed()

var receiver: Object:
	set(value):
		receiver = value
		%ReceiverPath.text = "${0} ({1})".format([from.get_path_to(receiver), receiver.name])
		%FunctionName.anchor = anchor
		%FunctionName.node = receiver

func set_expression_mode(expr: bool):
	%Receiver.visible = not expr
	%Expression.visible = expr
	%Expression.text = ''

func default_focus():
	if %Expression.visible:
		%Expression.grab_focus()
	else:
		%FunctionName.grab_focus()

func _process(delta):
	if anchor and anchor.is_inside_tree():
		position = Utils.popup_position(anchor)
		%FunctionName.anchor = anchor

var selected_signal: Dictionary:
	set(value):
		selected_signal = value
		%Signal.text = Utils.print_signal(value)

func set_existing_connection(from: Node, connection: Connection):
	self.from = from
	existing_connection = connection
	selected_signal = Utils.find(from.get_signal_list(), func (s): return s["name"] == connection.signal_name)
	if connection.is_target():
		receiver = from.get_node(connection.to)
		%FunctionName.anchor = anchor
		%FunctionName.text = connection.invoke
		_on_function_selected(connection.invoke)
	else:
		%Expression.text = connection.expression
	
	%Receiver.visible = connection.is_target()
	%Expression.visible = connection.is_expression()
	
	for i in range(%Args.get_child_count()):
		%Args.get_child(i).text = connection.arguments[i] if i <= connection.arguments.size() - 1 else ""

func _on_function_selected(name: String):
	var method = Utils.find(receiver.get_method_list(), func (m): return m["name"] == name)
	
	for child in %Args.get_children():
		%Args.remove_child(child)
		child.queue_free()
	
	if method == null:
		return
	
	var ArgUI = load("res://addons/pronto/signal_connecting/argument.tscn")
	for arg in method["args"]:
		var arg_ui = ArgUI.instantiate()
		arg_ui.arg_name = arg["name"]
		%Args.add_child(arg_ui)
	if not %Args.get_children().is_empty():
		%Args.get_children().back().is_last = true

func _on_done_pressed():
	if %Receiver.visible:
		var args = %Args.get_children().map(func (c): return c.text)
		var invoke = %FunctionName.text
		if invoke.length() == 0 or args.any(func (a): return a.length() == 0): return
		if existing_connection:
			existing_connection.arguments = args
			existing_connection.invoke = invoke
		else:
			Connection.connect_target(from, selected_signal["name"], from.get_path_to(receiver), invoke, args)
	if %Expression.visible:
		if existing_connection:
			existing_connection.expression = %Expression.text
		else:
			Connection.connect_expr(from, selected_signal["name"], %Expression.text)
	queue_free()

func _on_remove_pressed():
	if existing_connection:
		existing_connection.delete(from)
	queue_free()

func _on_cancel_pressed():
	queue_free()
