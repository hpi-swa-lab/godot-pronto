@tool
#thumb("CylinderMesh")
extends Behavior
class_name State

### When enabled, add the value of all properties to the global G dictionary as well.
@export var global = false

var _last_reported_game_values = {}

signal changed(prop: String, old_value: Variant, new_value: Variant)

func _ready():
	super._ready()
	if global and not Engine.is_editor_hint():
		for prop in get_meta_list():
			G._register_state(self, prop)
			G.put(prop, get_meta(prop))

func inc(prop: String, amount = 1):
	var value = get_meta(prop) + amount
	put(prop, value)

func put(prop: String, value: Variant):#
	var old_value = get_meta(prop)
	set_meta(prop, value)
	if global:
		G._put(prop, value)
	changed.emit(prop, old_value, value)
	EngineDebugger.send_message("pronto:state_put", [get_path(), prop, value])

func at(prop: String, default = null):
	return get_meta(prop, default)

func _report_game_value(prop: String, value: Variant):
	_last_reported_game_values[prop] = value

func lines():
	return super.lines() + [Lines.BottomText.new(self, _print_values())]

func _print_values():
	return "\n".join(Array(get_meta_list()).map(func (prop):
		return "{0} = {1}{2}".format([prop, get_meta(prop), _last_reported_string(prop)])))

func _last_reported_string(prop: String):
	var val = _last_reported_game_values.get(prop)
	if val != null:
		return " ({0})".format([val])
	else:
		return ""
