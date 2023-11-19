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
		StateConnectionConfigurator.open_new_invoke(undo_redo, data["source"], source_signal, node)
	else:
		NodeToNodeConfigurator.open_new_invoke(undo_redo, data["source"], source_signal, node)
