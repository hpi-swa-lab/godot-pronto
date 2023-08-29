@tool
extends Node

### Helper autoload that stores constants
### and utility functoins for promoting
### text selection to ValueBehavior.

## The id for the Promote to Value menu item
var MENU_PROMOTE_VALUE = 100

## The regex used for matching the text selection
var value_regex = RegEx.new()

## Checks if the selection can be promoted to a ValueBehavior
func is_valid_selection(selection: String):
	return value_regex.search(selection) != null

## Creates a new ValueBehavior for the text selection
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
	
func _ready():
	if Engine.is_editor_hint():
		value_regex.compile("^\\s*(([+-]?([0-9]*[.])?[0-9]+|true|false)(:([a-zA-Z0-9_]+))?)\\s*$")
