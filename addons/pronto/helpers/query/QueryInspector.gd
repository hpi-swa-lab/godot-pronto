extends EditorInspectorPlugin

class_name QueryInspector

func _can_handle(object):
	return object is QueryBehavior

func _parse_property(object, type, name, hint_type, hint_string, usage_flags, wide):
	if name == "queries":
		add_property_editor(name, QueryProperty.new())
		return true
	
	return false

class QueryProperty extends EditorProperty:
	var control: Control
	var updating = false
	var current_value: Array[Query]
	
	func _init():
		control = preload("res://addons/pronto/helpers/query/QueryEditor.tscn").instantiate()
		control.added_query.connect(_on_added_query)
		control.removed_query.connect(_on_removed_query)
		control.changed_query.connect(_on_changed_query)
		
		add_child(control)
		set_bottom_editor(control)
	
	func _ready():
		control.query_behavior = get_edited_object()
	
	func _on_added_query(query: Query):
		if updating:
			push_error("Failed to add query because updating was in progress")
			return
		
		current_value.append(query)
		control.queries = current_value
		control.update_queries()
		emit_changed(get_edited_property(), current_value)
		get_edited_object().queue_redraw()
	
	func _on_removed_query(query: Query):
		if updating:
			push_error("Failed to remove query because updating was in progress")
			return
		
		current_value.remove_at(current_value.find(query))
		control.queries = current_value
		control.update_queries()
		emit_changed(get_edited_property(), current_value)
		get_edited_object().queue_redraw()
	
	func _on_changed_query():
		if updating:
			push_error("Failed to change query because updating was in progress")
			return
		
		control.update_queries()
		emit_changed(get_edited_property(), current_value)
		get_edited_object().queue_redraw()
	
	func _update_property():
		var new_value = get_edited_object()[get_edited_property()]
		if current_value == new_value:
			return
		
		updating = true
		current_value = new_value
		control.queries = current_value
		control.update_queries()
		updating = false
