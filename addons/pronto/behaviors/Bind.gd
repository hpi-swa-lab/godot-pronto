@tool
#thumb("EditBezier")
extends Behavior

@export var from: Array[SourceProp]
@export var to_prop: String
@export var convert: String
### Update only when the update() function is called.
@export var one_shot: bool = false

var last = []

func update():
	var inputs = []
	for f in from:
		var object = get_node(f.from)
		assert(object != null, "Object is no longer at path {0}".format([f.from]))
		var current
		if f.prop in object:
			current = object.get(f.prop)
		else:
			current = object.get_meta(f.prop)
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

func _process(delta):
	super._process(delta)
	
	if not Engine.is_editor_hint() and not one_shot:
		update()
