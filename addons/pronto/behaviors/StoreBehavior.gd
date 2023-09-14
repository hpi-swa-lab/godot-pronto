@tool
#thumb("CylinderMesh")
extends Behavior
class_name StoreBehavior

## Mapping from field names to expressions initializing each field
@export var fields: Dictionary = {}

## Mapping from field names to current values
var data = {}

var _last_reported_game_values = {}

## Emitted on change and when the store first becomes ready.
## Also provides a stringified version of the value.
signal sync(prop: String, value: Variant, text: String)

## Emitted whenever the property changes
signal changed(prop: String, value: Variant)

func _ready():
	super._ready()
	if Engine.is_editor_hint():
		return
	for prop in fields:
		data[prop] = fields[prop].run()
		sync.emit(prop, data[prop], str(data[prop]))

func inc(prop: String, amount = 1):
	var value = data.get(prop) + amount
	put(prop, value)

func dec(prop: String, amount = 1):
	inc(prop, -amount)

func put(prop: String, value: Variant):
	data[prop] = value
	changed.emit(prop, value)
	sync.emit(prop, value, str(value))
	if EngineDebugger.is_active(): EngineDebugger.send_message("pronto:store_put", [get_path(), prop, value])

func update(prop: String, call: Callable):
	put(prop, call.call(at(prop)))
	return at(prop)

func at(prop: String, default = null):
	return data.get(prop, default)

func at_and_remove(prop: String, default = null):
	var val = at(prop, default)
	if data.has(prop):
		data.erase(prop)
	return val

func _report_game_value(prop: String, value: Variant):
	_last_reported_game_values[prop] = value

func lines():
	return super.lines() + [Lines.BottomText.new(self, _print_values())]

func _print_values():
	return "\n".join(Array(fields.keys()).filter(func (p): return p != "pronto_connections").map(func (prop):
		return "{0} = {1}{2}".format([prop, str(data.get(prop)), _last_reported_string(prop)])))

func _last_reported_string(prop: String):
	var val = _last_reported_game_values.get(prop)
	if val != null:
		return " ({0})".format([val])
	else:
		return ""
