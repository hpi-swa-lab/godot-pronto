extends HBoxContainer
class_name DragSignal

var from: Node
var drop_destinations: Array
var source_signal

var DropList = load("res://addons/prototyping/signal_connecting/drop_list.tscn")

func _init(s: Dictionary, from: Node):
	source_signal = s
	var l = Label.new()
	l.text = Utils.print_signal(s)
	add_child(l)
	self.from = from

func _get_drag_data(at_position):
	show_drop_destinations()
	return {"type": "P_CONNECT_SIGNAL", "signal": source_signal, "source": from}

func show_drop_destinations():
	var groups = []
	drop_destinations = cluster(from.get_viewport()).map(func (cluster):
		var list = DropList.instantiate()
		list.nodes = cluster
		Utils.spawn_popup_from_canvas(cluster[0], list)
		return list)

func rect(node):
	return Rect2(node.global_position, Vector2(100, 100))

func cluster(root_node, cluster_radius = 100):
	var nodes = Utils.all_nodes_that(root_node, func (n): return Utils.has_position(n))
	var positions: Array = nodes.map(func (node): return node.global_position)
	
	var clusters = []
	while not nodes.is_empty():
		var start = nodes.pop_front()
		var cluster = [start]
		for node in nodes:
			if rect(start).intersects(rect(node)):
				cluster.append(node)
		for node in cluster:
			nodes.erase(node)
		clusters.append(cluster)
	
	return clusters

func _notification(what):
	if what == NOTIFICATION_DRAG_END:
		for d in drop_destinations: d.queue_free()
		drop_destinations = []
