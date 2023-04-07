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
		print(arg)
		var arg_ui = ArgUI.instantiate()
		arg_ui.arg_name = arg["name"]
		%Args.add_child(arg_ui)
	if not %Args.get_children().is_empty():
		%Args.get_children().back().is_last = true

func _on_done_pressed():
	queue_free()
