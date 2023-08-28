@tool
extends Node

### Helper autoload that stores global values.
###
### Access via G.at("prop").

var values = {}
var _store_update = {}

var PROMOTE_IDX = 100
var value_regex = RegEx.new()
		
func _promote_selection_to_value(selection: String):
	var regex_groups: PackedStringArray = value_regex.search(selection).strings
	
	var timestamp = str(floor(Time.get_unix_time_from_system() * 100))
	var value_name = regex_groups[5] if not regex_groups[5].is_empty() \
		else "Value#" + timestamp
	
	var root = get_tree().get_edited_scene_root()
	var protoTypingUI = root.find_child("*PrototypingUIBehavior*", true, true)
	var insert_node = protoTypingUI if protoTypingUI else root
	
	var value = ValueBehavior.new()
	value.name = value_name
	
	var selected_value = regex_groups[2] # float number or bool
	
	if selected_value in ["true", "false"]:
		# Create Bool ValueBehavior.
		value.selectType = "Bool"
		value.bool_value = selected_value.to_upper()
	elif selected_value.is_valid_float():
		# Create Float ValueBehavior.
		var offset = 100
		var val = selected_value.to_float()
		value.selectType = "Float"
		value.float_from = floor(val - offset)
		value.float_to = ceil(val + offset)
		value.float_value = val
		
	insert_node.add_child(value, true)
	value.set_owner(root)
	
	var value_ref = selection.replace(regex_groups[1], "G.at(\"" + value_name + "\")")
	return value_ref

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
	else:
		value_regex.compile("^\\s*(([+-]?([0-9]*[.])?[0-9]+|true|false)(:([a-zA-Z0-9_]+))?)\\s*$")

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
