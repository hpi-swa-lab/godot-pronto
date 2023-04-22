@tool
#thumb("CylinderMesh")
extends Behavior
class_name State

### When enabled, add the value of all properties to the global G dictionary as well.
@export var global = false

signal changed(prop: String, value: Variant)

func _ready():
	super._ready()
	if global and not Engine.is_editor_hint():
		for prop in get_meta_list():
			G._register_state(self, prop)
			G.put(prop, get_meta(prop))

func inc(prop: String, amount = 1):
	var value = get_meta(prop) + amount
	put(prop, value)

func put(prop: String, value: Variant):
	set_meta(prop, value)
	if global:
		G._put(prop, value)
	changed.emit(prop, value)

func at(prop: String):
	return get_meta(prop)

func lines():
	return super.lines() + [Lines.Line.new(self, self, func (flip): return _print_values())]

func _print_values():
	return "\n".join(Array(get_meta_list()).map(func (prop): return "{0} = {1}".format([prop, get_meta(prop)])))
