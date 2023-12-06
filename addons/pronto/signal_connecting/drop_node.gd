@tool
extends HBoxContainer

var undo_redo: EditorUndoRedoManager

var node: Node:
	set(value):
		node = value
		%label.text = node.name
		var icon = Utils.icon_for_node(node, node)
		if icon:
			%icon.texture = icon

func _can_drop_data(at_position, data):
	return "type" in data and data["type"] == "P_CONNECT_SIGNAL"

func _drop_data(at_position, data):
	var source_signal = data["signal"]
	if source_signal["name"] == "on_trigger_received" and node is StateBehavior:
		StateTransitionConfigurator.open_new_invoke(undo_redo, data["source"], source_signal, node)
	else:
		NodeToNodeConfigurator.open_new_invoke(undo_redo, data["source"], source_signal, node)
	_study_logging("connection_create from " + data["source"].name + " to " + node.name + " of signal type " + _source_signal_print(source_signal))
	NodeToNodeConfigurator.open_new_invoke(undo_redo, data["source"], source_signal, node)

func _study_logging(text):
	var _study_tracker = get_node("/root/").find_child("StudyRoot", true, false)
	if _study_tracker.active:		
		_study_tracker.logger.log(text)

func _source_signal_print(source_signal):
	var str_representation = ""
	var name = source_signal.name
	str_representation += name
	var args = source_signal.args
	if len(args) > 0:
		str_representation += "("
		for arg in args:
			str_representation += arg.name + ", "
		str_representation += ")"
	return str_representation	
