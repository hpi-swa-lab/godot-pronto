@tool
extends PanelContainer

var anchor: Node

func _process(delta):
	position = anchor.get_viewport_transform() * anchor.global_position

var selected_signal: Dictionary:
	set(value):
		selected_signal = value
		var desc = selected_signal["name"] + "( "
		var args = selected_signal["args"]
		desc += args.slice(1).reduce(func(acc, arg): return acc + ", " + arg["name"], args.front()["name"])
		desc += " )"
		$MarginContainer/VBoxContainer/HBoxContainer/Signal.text = desc

var receiver: Object:
	set(value):
		receiver = value
		receiver_methods = Dictionary()
		for method in receiver.get_method_list():
			$MarginContainer/VBoxContainer/Receiver/Function.add_item(method["name"])
			receiver_methods[method["name"]] = method

var receiver_methods

func _on_function_item_selected(index):
	if receiver_methods == null:
		return
	var method = receiver_methods[$MarginContainer/VBoxContainer/Receiver/Function.get_item_text(index)]
	
	for child in $MarginContainer/VBoxContainer/Receiver/Args.get_children():
		$MarginContainer/VBoxContainer/Receiver/Args.remove_child(child)
		child.queue_free()
	
	var ArgUI = load("res://addons/prototyping/signal_connecting/argument.tscn")
	for arg in method["args"]:
		print(arg)
		var arg_ui = ArgUI.instantiate()
		arg_ui.arg_name = arg["name"]
		$MarginContainer/VBoxContainer/Receiver/Args.add_child(arg_ui)
	$MarginContainer/VBoxContainer/Receiver/Args.get_children().back().is_last = true
