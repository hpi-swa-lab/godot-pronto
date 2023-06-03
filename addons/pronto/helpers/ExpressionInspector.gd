extends EditorInspectorPlugin
class_name ExpressionInspector

func _can_handle(object):
	return (object is Bind
		or object is Code
		or object is Watch
		or object is Node and object.get_child_count() > 0 and object.get_child(0) is Bind)

func _parse_property(object, type, name, hint_type, hint_string, usage_flags, wide):
	if (object is Bind and name == "convert"
	or object is Code and name == "code"
	or object is Watch and name == "expression"):
		add_property_editor(name, ExpressionProperty.new())
		return true
	if object is Node and object.get_child_count() > 0 and object.get_child(0) is Bind and object.get_child(0).to_prop == name:
		add_property_editor(name, BoundProperty.new(object.get_child(0)))
		return true
	return false

class ExpressionProperty extends EditorProperty:
	var editor
	var my_update = false
	func _init():
		editor = preload("res://addons/pronto/signal_connecting/expression_edit.tscn").instantiate()
		editor.size_flags_horizontal = SIZE_EXPAND_FILL # Make the expression window take the full width
		add_child(editor)
		editor.text_changed.connect(func ():
			if not my_update:
				emit_changed(get_edited_property(), editor.text))
	
	func _update_property():
		var val = get_edited_object()[get_edited_property()]
		if editor.text != val:
			my_update = true
			editor.text = val
			my_update = false

class BoundProperty extends EditorProperty:
	func _init(bind: Bind):
		var l = Button.new()
		l.text = "Bound. Click to see Bind."
		l.pressed.connect(func ():
			var s = G.at("_pronto_editor_plugin").get_editor_interface().get_selection()
			s.clear()
			s.add_node(bind))
		add_child(l)
	func _update_property():
		pass
