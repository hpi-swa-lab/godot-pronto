extends VBoxContainer
class_name PMethod

var target: Node
var target_method: Dictionary

func _init(method: Dictionary, target: Node):
	self.target = target
	self.target_method = method
	
	size_flags_horizontal = Control.SIZE_EXPAND_FILL
	
	var l = Label.new()
	l.text = method['name']
	add_child(l)

func _can_drop_data(at_position, data):
	return "type" in data and data["type"] == "P_CONNECT_SIGNAL"

func _drop_data(at_position, data):
	print(data)
	var source_signal = data["signal"]
	data["source"].connect(source_signal["name"], func(): Callable(target, target_method["name"]).call(), CONNECT_PERSIST)
