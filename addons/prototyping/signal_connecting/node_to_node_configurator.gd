@tool
extends PanelContainer

var anchor: Node

func _process(delta):
	if anchor:
		position = Utils.popup_position(anchor)

var selected_signal: Dictionary:
	set(value):
		selected_signal = value
		%Signal.text = Utils.print_signal(value)

func set_existing_connection(from: Node, connection: Connection):
	receiver = from
	selected_signal = Utils.find(from.get_signal_list(), func (s): return s["name"] == connection.signal_name)
	
	var function_index = Utils.find_index(receiver.get_method_list(), func (i): return i["name"] == connection.invoke)
	%Function.select(function_index)
	_on_function_item_selected(function_index)
	
	for i in range(%Args.get_child_count()):
		print(connection.arguments[i])
		%Args.get_child(i).text = connection.arguments[i]

var receiver: Object:
	set(value):
		receiver = value
		receiver_methods = Dictionary()
		for method in receiver.get_method_list():
			%Function.add_item(method["name"])
			receiver_methods[method["name"]] = method

var receiver_methods

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
	queue_free()
