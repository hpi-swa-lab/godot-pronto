extends HBoxContainer
class_name DragSignal

var from: Node
var drop_destinations: Array
var source_signal: Dictionary
var undo_redo: EditorUndoRedoManager

var DropList = preload("res://addons/pronto/signal_connecting/drop_list.tscn")

func _init(s: Dictionary, from: Node, undo_redo: EditorUndoRedoManager):
	source_signal = s
	self.undo_redo = undo_redo
	var l = Label.new()
	l.text = Utils.print_signal(s)
	add_child(l)
	self.from = from

func _gui_input(event):
	if event is InputEventMouseButton and event.double_click:
		NodeToNodeConfigurator.open_new_expression(undo_redo, from, source_signal)

func _get_drag_data(at_position):
	show_drop_destinations()
	return {"type": "P_CONNECT_SIGNAL", "signal": source_signal, "source": from}

func show_drop_destinations():
	var groups = []
	drop_destinations = cluster(from.get_viewport(), 40 / from.get_viewport_transform().get_scale().x).map(func (cluster):
		var list = DropList.instantiate()
		list.undo_redo = undo_redo
		list.nodes = cluster
		Utils.spawn_popup_from_canvas(cluster[0], list)
		return list)

func rect(node: CanvasItem, extent: float):
	return Rect2(node.global_position, Vector2(extent, extent))

func cluster(root_node, extent = 100):
	var nodes = Utils.all_nodes_that(root_node, func (n): return Utils.has_position(n))
	var positions: Array = nodes.map(func (node): return node.global_position)
	
	var clusters = []
	while not nodes.is_empty():
		var start = nodes.pop_front()
		var cluster = [start]
		for node in nodes:
			if rect(start, extent).intersects(rect(node, extent)):
				cluster.append(node)
		for node in cluster:
			nodes.erase(node)
		clusters.append(cluster)
	
	return clusters

func _notification(what):
	if what == NOTIFICATION_DRAG_END:
		for d in drop_destinations: d.queue_free()
		drop_destinations = []
