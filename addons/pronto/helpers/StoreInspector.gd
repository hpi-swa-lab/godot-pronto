extends EditorInspectorPlugin
class_name StoreInspector

func _can_handle(object):
	return object is StoreBehavior

func _parse_property(object, type, name, hint_type, hint_string, usage_flags, wide):
	if name == 'fields':
		add_property_editor(name, FieldsProperty.new())
		return true
	return false

class FieldsProperty extends EditorProperty:
	func fields():
		return get_edited_object()[get_edited_property()]
	
	func _update_property():
		for child in get_children(): child.queue_free()
		
		var column = VBoxContainer.new()
		add_child(column)
		
		var fields = get_edited_object()[get_edited_property()]
		if fields == null: fields = {}
		
		for key in fields:
			var old_key = {key = key}
			var key_editor = LineEdit.new()
			key_editor.text = key
			key_editor.size_flags_horizontal = SIZE_EXPAND_FILL
			key_editor.text_changed.connect(func (new_key):
				var new = fields().duplicate()
				var script = fields()[old_key.key]
				new.erase(old_key.key)
				new[new_key] = script
				old_key.key = new_key
				emit_changed(get_edited_property(), new, "", true))
			
			var expression_editor = preload("res://addons/pronto/signal_connecting/expression_edit.tscn").instantiate()
			expression_editor.edit_script = fields[key]
			expression_editor.control_argument_names = false
			expression_editor.size_flags_horizontal = SIZE_EXPAND_FILL
			expression_editor.blur.connect(func ():
				var new = fields().duplicate()
				expression_editor.apply_changes()
				new[key_editor.text] = expression_editor.edit_script
				emit_changed(get_edited_property(), new, "", true))
			
			var first_row = HBoxContainer.new()
			var delete = Button.new()
			delete.text = "x"
			delete.pressed.connect(func ():
				var new = fields().duplicate()
				new.erase(key_editor.text)
				emit_changed(get_edited_property(), new, "", false))
			
			first_row.add_child(key_editor)
			first_row.add_child(delete)
			
			var container = VBoxContainer.new()
			container.add_child(first_row)
			container.add_child(expression_editor)
			container.add_child(HSeparator.new())
			column.add_child(container)
		
		var add = Button.new()
		add.text = "Add Field"
		add.pressed.connect(func ():
			var new = {"": ConnectionScript.new()}
			new.merge(fields())
			emit_changed(get_edited_property(), new, "", false))
		column.add_child(add)
