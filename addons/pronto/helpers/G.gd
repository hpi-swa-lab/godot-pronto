@tool
extends Node

### Helper autoload that stores global values.
###
### Access via G.at("prop").

var values = {}

func put(name: String, value: Variant):
	values[name] = value

func at(name: String, default = null):
	if name in values:
		return values[name]
	else:
		return default

func inc(prop: String, amount = 1):
	var value = values[prop] + amount
	put(prop, value)
