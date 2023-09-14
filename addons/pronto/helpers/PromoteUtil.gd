@tool
extends Node

### Helper autoload that stores constants
### and utility functoins for promoting
### text selection to ValueBehavior.

## The id for the Promote to Value menu item
var MENU_PROMOTE_VALUE = 100

## The regex used for matching the text selection
var value_regex = RegEx.new()

## The tooltip used for the menu item
func _tool_tip():
	return "Selection has to match <Float|Bool>[:Name]?"

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
		value.float_min = floor(val - offset)
		value.float_max = ceil(val + offset)
		value.float_value = val
		
	insert_node.add_child(value, true)
	value.set_owner(root)
	
	var value_ref = selection.replace(regex_groups[1], "G.at(\"" + value_name + "\")")
	return value_ref
	
func _ready():
	if Engine.is_editor_hint():
		value_regex.compile("^\\s*(([+-]?([0-9]*[.])?[0-9]+|true|false)(:([a-zA-Z0-9_]+))?)\\s*$")


######################
# Code for installing the menu item
######################

func install_menu_item(editor_interface):
	tab_container = editor_interface.get_script_editor().find_child(
		"*TabContainer*", true, false)
	if tab_container:
		tab_container.tab_changed.connect(_tab_changed)

func uninstall():
	tab_container.tab_changed.disconnect(_tab_changed)

var tab_container: TabContainer

func _tab_changed(tab: int):
	var popup_menu = tab_container.get_tab_control(tab).find_child("*PopupMenu*", true, false)
	if popup_menu and popup_menu is PopupMenu:
		if not popup_menu.about_to_popup.is_connected(_about_to_popup):
			popup_menu.about_to_popup.connect(_about_to_popup)

func _about_to_popup():
	var current_tab = tab_container.get_current_tab_control()
	var code_edit = current_tab.get_base_editor()
	var current_edit_menu = current_tab.find_child("*PopupMenu*", true, false)
	
	if not current_edit_menu: 
		return
		
	var selection: String = code_edit.get_selected_text()
	var valid = is_valid_selection(selection)

	current_edit_menu.add_item("Promote to Value [Pronto]", PromoteUtil.MENU_PROMOTE_VALUE)
	current_edit_menu.set_item_tooltip(-1, PromoteUtil._tool_tip())
	
	if not selection.is_empty() and valid:
		if not current_edit_menu.id_pressed.is_connected(_on_item_pressed):
			current_edit_menu.id_pressed.connect(_on_item_pressed)
	else:
		# Disaple Promote to Value options
		current_edit_menu.set_item_disabled(-1, true)

func _on_item_pressed(id):
	var code_edit = tab_container.get_current_tab_control().get_base_editor()
	if id == PromoteUtil.MENU_PROMOTE_VALUE:
		var selection: String = code_edit.get_selected_text()
		if Engine.is_editor_hint():
			var value_ref = PromoteUtil._promote_selection_to_value(selection)
			code_edit.insert_text_at_caret(value_ref)
