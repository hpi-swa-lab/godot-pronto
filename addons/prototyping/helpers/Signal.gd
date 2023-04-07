extends HBoxContainer
class_name PSignal

var from: Node
var drop_destinations: Array
var source_signal

var DropList = load("res://addons/prototyping/signal_connecting/drop_list.tscn")

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
	# TODO merge by distance instead
	drop_destinations = (Utils.all_nodes_that(from.get_viewport(), func (c): return Utils.has_position(c))
		.map(func (drop):
			var list = DropList.instantiate()
			list.node = drop
			Utils.spawn_popup_from_canvas(drop, list)
			return list))

func _notification(what):
	if what == NOTIFICATION_DRAG_END:
		for d in drop_destinations: d.queue_free()
		drop_destinations = []
