extends EditorInspectorPlugin
class_name ExpressionInspector

class ExpressionProperty extends EditorProperty:
	var editor
	var my_update = false
	func _init():
		editor = preload("res://addons/pronto/signal_connecting/expression_edit.tscn").instantiate()
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

func _can_handle(object):
	return object is Bind

func _parse_property(object, type, name, hint_type, hint_string, usage_flags, wide):
	if name == "convert":
		add_property_editor(name, ExpressionProperty.new())
		return true
	return false
