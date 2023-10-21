@tool
extends VBoxContainer

signal added_query(query: Query)
signal removed_query(query: Query)
signal changed_query

var query_types = [
	ProximityQuery,
	GroupQuery,
	ClassQuery,
	DescendantQuery,
	PredicateQuery,
	]

var query_behavior: QueryBehavior
var queries: Array[Query]

func _ready():
	# workaround to make the MenuButton use the default button style
	var button_theme = get_tree().get_root().theme
	$AddQueryButton.set("theme_override_styles/normal", button_theme.get_theme_item(Theme.DATA_TYPE_STYLEBOX, "normal", "Button"))
	
	var popup: PopupMenu = $AddQueryButton.get_popup()
	popup.id_pressed.connect(_add_query_button_selected_item)
	var icon = EditorIcon.new()
	icon.name = "Search"
	for i in range(query_types.size()):
		var q = query_types[i]
		popup.add_icon_item(icon, q.name(), i)

func update_queries():
	Utils.remove_children(%QueryContainer)
	for query in queries:
		var l = Label.new()
		l.text = "and"
		l.set("theme_override_colors/font_color", get_theme_color("readonly_color", "Editor"))
		%QueryContainer.add_child(l)
		
		var editor_container = preload("res://addons/pronto/helpers/query/QueryEditorContainer.tscn").instantiate()
		editor_container.query = query
		editor_container.removed_query.connect(func(q): removed_query.emit(q))
		editor_container.changed_query.connect(func(): changed_query.emit())
		
		var query_editor = editor_container.get_query_editor()
		if query_editor.has_signal("changed_query"):
			query_editor.changed_query.connect(func(): changed_query.emit())
		if query_editor.has_method("set_query_behavior"):
			query_editor.set_query_behavior(query_behavior)
		%QueryContainer.add_child(editor_container)
	
	%QueryContainer.remove_child(%QueryContainer.get_child(0))


func _on_add_query_button_pressed():
	emit_signal("added_query", GroupQuery.new())


func _add_query_button_selected_item(id):
	var popup = $AddQueryButton.get_popup()
	emit_signal("added_query", query_types[id].new())
