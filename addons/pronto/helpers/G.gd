@tool
extends Node

### Helper autoload that stores global values.
###
### Access via G.at("prop").

var values = {}
var _store_update = {}

func put(name: String, value: Variant):
	_put(name, value)
	if name in _store_update:
		_store_update[name].put(name, value)

func at(name: String, default = null):
	if name in values:
		return values[name]
	else:
		return default
		
func at_and_remove(name: String, default = null):
	var val = at(name,default)
	if(name in values):
		values.erase(name)
	return val
		

func default(name: String, call: Callable):
	if not name in values:
		values[name] = call.call()
	return values[name]

func inc(prop: String, amount = 1):
	var value = values[prop] + amount
	put(prop, value)

func _put(name: String, value: Variant):
	values[name] = value

func _register_store(store: StoreBehavior, prop: String):
	assert(not prop in _store_update, "Property {0} has already been registered by a store node. Are you spawning the same Store mutliple times?".format([prop]))
	_store_update[prop] = store

func _ready():
	if not Engine.is_editor_hint():
		maybe_add_value_user_interface()

func maybe_add_value_user_interface():
	if not Utils.all_nodes_that(get_tree().root, func (node): return node is PrototypingUIBehavior).is_empty():
		return
	
	var panel = PanelContainer.new()
	panel.size = Vector2(300, 200)
	var ui = PrototypingUIBehavior.new()
	ui.name = 'Config'
	panel.add_child(ui)
	
	var added_any = [false]
	Utils.all_nodes_do(get_tree().root, func (node):
		if ui.maybe_add_config(node):
			added_any[0] = true)
	if added_any[0]:
		add_child(panel)
