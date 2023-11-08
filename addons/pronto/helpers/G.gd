@tool
extends Node

### Helper autoload that stores global values.
###
### Access via G.at("prop").

var values = {}
var _store_update = {}
var current_root = null

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
		get_tree().tree_changed.connect(maybe_add_value_user_interface)
		

func maybe_add_value_user_interface():
	if (current_root and current_root.get_ref()): return
	current_root = weakref(get_tree().current_scene)
	if not Utils.all_nodes_that(get_tree().root, func (node): return node is PrototypingUIBehavior).is_empty():
		return
	
	await get_tree().process_frame
	var ui = PrototypingUIBehavior.new()
	ui.name = 'Config'
	# Place the PrototypingUI in its own CanvasLayer
	var canvasLayer = CanvasLayer.new()
	canvasLayer.add_child(ui)
	get_tree().current_scene.add_child(canvasLayer)
