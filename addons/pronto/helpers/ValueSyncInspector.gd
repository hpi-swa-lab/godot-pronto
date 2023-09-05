extends EditorInspectorPlugin
class_name ValueSyncInspector

func _can_handle(object):
	return object is PrototypingUIBehavior

func _parse_property(object, type, name, hint_type, hint_string, usage_flags, wide):
	if object is PrototypingUIBehavior and name == "runtime_values":
		add_property_editor(name, ButtonProperty.new())
		return true
	else:
		return false

class ButtonProperty extends EditorProperty:
	# The main control for editing the property.
	var property_control = Button.new()
	func _init():
		# Add the control as a direct child of EditorProperty node.
		add_child(property_control)
		# Make sure the control is able to retain the focus.
		add_focusable(property_control)
		# Setup the initial state and connect to the signal to track changes.
		property_control.pressed.connect(_on_button_pressed)
		property_control.text = "Sync ⟳"
	
	func _get_value_children(node):
		var child_nodes = []
		for child in node.get_children():
			if child is ValueBehavior:
				child_nodes.push_back(child)
			child_nodes.append_array(_get_value_children(child))
		return child_nodes
		
	func _update_value(res: ValueResource, value: ValueBehavior):
		if res.selectType != value.selectType:
			return
		match value.selectType:
			"Float":
				value.float_step_size = res.float_step_size
				value.float_from = res.float_from
				value.float_to = res.float_to
				value.float_value = res.float_value
			"Enum":
				value.enum_value = res.enum_value
			"Bool":
				value.bool_value = res.bool_value

	func _on_button_pressed():
		var root = get_tree().get_edited_scene_root()
		var value_objects = _get_value_children(root)
		for value_obj in value_objects:
			var path = "res://addons/pronto/value_resources/" + value_obj.name + ".res"
			var file = FileAccess.open(path,
				FileAccess.READ)
			if not file: return
			var r = ResourceLoader.load(path)
			if r is ValueResource:
				var val_res = (r as ValueResource)
				_update_value(val_res, value_obj)
			file.close()
		
