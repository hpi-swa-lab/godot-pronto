@tool
extends HBoxContainer

var query: Query:
	set(value):
		query = value
		
		$ActiveCheckBox.button_pressed = query.active
		
		var e = query.query_editor()
		add_child(e)
		move_child(e, 0)


signal removed_query(query: Query)
signal changed_query


func _enter_tree():
	if query != null and not query.active:
		theme = Theme.new()
		var disabled_color = get_theme_color("readonly_color", "Editor")
		theme.set_color("font_color", "Label", disabled_color)

func _on_remove_button_pressed():
	removed_query.emit(query)


func get_query_editor():
	if query == null:
		push_error("Tried to get query editor from container without query")
		return null
	
	return get_child(0)


func _on_active_check_box_toggled(button_pressed):
	query.active = button_pressed
	changed_query.emit()
