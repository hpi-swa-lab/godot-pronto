@tool
extends PanelContainer

var anchor: Node
var from: Node
var existing_connection = null

var receiver: Object:
	set(value):
		receiver = value
		receiver_methods = Dictionary()
		for method in receiver.get_method_list():
			%Function.add_item(method["name"])
			receiver_methods[method["name"]] = method

var receiver_methods

func _process(delta):
	if anchor:
		position = Utils.popup_position(anchor)

var selected_signal: Dictionary:
	set(value):
		selected_signal = value
		%Signal.text = Utils.print_signal(value)

func set_existing_connection(from: Node, connection: Connection):
	existing_connection = connection
	receiver = from.get_node(connection.to)
	self.from = from
	selected_signal = Utils.find(from.get_signal_list(), func (s): return s["name"] == connection.signal_name)
	
	var function_index = Utils.find_index(receiver.get_method_list(), func (i): return i["name"] == connection.invoke)
	%Function.select(function_index)
	_on_function_item_selected(function_index)
	
	for i in range(%Args.get_child_count()):
		print(connection.arguments[i])
		%Args.get_child(i).text = connection.arguments[i]

func _on_function_item_selected(index):
	if receiver_methods == null:
		return
	var method = receiver_methods[%Function.get_item_text(index)]
	
	for child in %Args.get_children():
		%Args.remove_child(child)
		child.queue_free()
	
	var ArgUI = load("res://addons/prototyping/signal_connecting/argument.tscn")
	for arg in method["args"]:
		var arg_ui = ArgUI.instantiate()
		arg_ui.arg_name = arg["name"]
		%Args.add_child(arg_ui)
	if not %Args.get_children().is_empty():
		%Args.get_children().back().is_last = true

func _on_done_pressed():
	var args = %Args.get_children().map(func (c): return c.text)
	var invoke = receiver.get_method_list()[%Function.selected]["name"]
	if existing_connection:
		existing_connection.arguments = args
		existing_connection.invoke = invoke
	else:
		Connection.connect_target(from, %Signal.text, from.get_path_to(receiver), invoke, args)
	queue_free()

func _on_remove_pressed():
	if existing_connection:
		existing_connection.delete(from)
	queue_free()
