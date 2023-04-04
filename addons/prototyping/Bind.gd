extends Node
class_name PBind

@export var from: Array[NodePath]
@export var from_prop: Array[String]
@export var to_prop: String
@export var convert: String

var last = []

func _process(delta):
	var inputs = []
	for i in range(from.size()):
		var object = get_node(from[i])
		var current
		if from_prop[i] in object:
			current = object.get(from_prop[i])
		else:
			current = object.get_meta(from_prop[i])
		inputs.append(current)
	
	if last == inputs:
		return
	
	var value = inputs[0] if inputs.is_empty() else null
	if convert:
		var e = Expression.new()
		e.parse(convert, range(from.size()).map(func (index): return "value" + str(index)))
		value = e.execute(inputs)
	get_parent().set(to_prop, value)
	
	last = inputs
