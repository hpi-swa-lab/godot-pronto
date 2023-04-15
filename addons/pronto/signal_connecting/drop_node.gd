@tool
extends HBoxContainer

var NodeToNodeConfigurator = load("res://addons/pronto/signal_connecting/node_to_node_configurator.tscn")

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
	
	var popup = NodeToNodeConfigurator.instantiate()
	popup.selected_signal = source_signal
	popup.from = data["source"]
	popup.receiver = node
	popup.set_expression_mode(false)
	popup.anchor = Utils.parent_that(node, func (n): return Utils.has_position(n))
	Utils.spawn_popup_from_canvas(node, popup)
	popup.default_focus()
