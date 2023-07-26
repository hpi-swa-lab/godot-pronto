extends EditorInspectorPlugin
class_name ExpressionInspector

func _can_handle(object):
	return (object is Node and 'wants_expression_inspector' in object
		or object is Node and object.get_child_count() > 0 and object.get_child(0) is BindBehavior)

func _parse_property(object, type, name, hint_type, hint_string, usage_flags, wide):
	if ('wants_expression_inspector' in object and object.wants_expression_inspector(name)):
		add_property_editor(name, ExpressionProperty.new())
		return true
	if object is Node and object.get_child_count() > 0 and object.get_child(0) is BindBehavior and object.get_child(0).to_prop == name:
		add_property_editor(name, BoundProperty.new(object.get_child(0)))
		return true
	return false

class ExpressionProperty extends EditorProperty:
	var editor
	func _init():
		editor = preload("res://addons/pronto/signal_connecting/expression_edit.tscn").instantiate()
		editor.control_argument_names = false
		editor.size_flags_horizontal = SIZE_EXPAND_FILL # Make the expression window take the full width
		add_child(editor)
		editor.blur.connect(func ():
			editor.apply_changes()
			emit_changed(get_edited_property(), editor.edit_script, "source_code", false))
	
	func _update_property():
		var val = get_edited_object()[get_edited_property()]
		if val == null:
			val = ConnectionScript.new()
			if 'initialize_connection_script' in get_edited_object():
				get_edited_object().initialize_connection_script(get_edited_property(), val)
		editor.edit_script = val

class BoundProperty extends EditorProperty:
	func _init(bind: BindBehavior):
		var l = Button.new()
		l.text = "Bound. Click to see Bind."
		l.pressed.connect(func ():
			var s = G.at("_pronto_editor_plugin").get_editor_interface().get_selection()
			s.clear()
			s.add_node(bind))
		add_child(l)
	func _update_property():
		pass
