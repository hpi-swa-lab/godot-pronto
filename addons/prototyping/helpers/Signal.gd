extends HBoxContainer
class_name PSignal

var from: Node
var drop_destinations: Array
var source_signal

func _init(s: Dictionary, from: Node):
	source_signal = s
	var l = Label.new()
	l.text = s['name']
	add_child(l)
	self.from = from

func _get_drag_data(at_position):
	show_drop_destinations()
	return {"type": "P_CONNECT_SIGNAL", "signal": source_signal, "source": from}

func show_drop_destinations():
	drop_destinations = (all_nodes_that(from.get_viewport(), is_visible_node)
		.map(func (drop): return PDrop.new(drop)))

func is_visible_node(node: Node):
	return node is Node3D or node is Control or node is Node2D

func all_nodes_that(root: Node, cond: Callable, list: Array[Node] = []):
	if cond.call(root):
		list.append(root)
	for c in root.get_children():
		all_nodes_that(c, cond, list)
	return list

func _notification(what):
	if what == NOTIFICATION_DRAG_END:
		for d in drop_destinations: d.queue_free()
		drop_destinations = []
