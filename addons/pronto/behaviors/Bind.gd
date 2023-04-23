@tool
#thumb("EditBezier")
extends Behavior
class_name Bind

@export var from: Array[SourceProp]
@export var to_prop: String
@export var convert: String
### Update only when the update() function is called.
@export var one_shot: bool = false

var last = null

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
	
	var value = null if inputs.is_empty() else inputs[0]
	if convert:
		value = ConnectionsList.eval(convert,
			range(from.size()).map(func (index): return "value" + str(index)),
			inputs,
			self)
	
	if last == value:
		return
	
	get_parent().set(to_prop, value)
	last = value

func _process(delta):
	super._process(delta)
	
	if not Engine.is_editor_hint() and not one_shot:
		update()

func _notification(what):
	match what:
		NOTIFICATION_PARENTED:
			add_line(Lines.DashedLine.new(self, get_parent(), "parent"))
		NOTIFICATION_UNPARENTED:
			remove_line("parent")

func text_for_line(line: Lines.Line, flipped: bool):
	if line.has_key("parent"):
		return Utils.ellipsize(convert, 20)
	else:
		return super.text_for_line(line, flipped)
