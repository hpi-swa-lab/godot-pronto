@tool
extends Node

### Helper autoload that stores global values.
###
### Access via G.at("prop").

var values = {}
var _state_update = {}

func put(name: String, value: Variant):
	_put(name, value)
	if name in _state_update:
		_state_update[name].put(name, value)

func at(name: String, default = null):
	if name in values:
		return values[name]
	else:
		return default

func inc(prop: String, amount = 1):
	var value = values[prop] + amount
	put(prop, value)

func _put(name: String, value: Variant):
	values[name] = value

func _register_state(state: State, prop: String):
	assert(not prop in _state_update, "Property {0} has already been registered by a state node.".format([prop]))
	_state_update[prop] = state
