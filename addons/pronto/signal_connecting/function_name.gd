@tool
extends LineEdit

var node
var anchor

signal method_selected(name: String)

func add_class_item(name):
	var behaviors = G.at("_pronto_behaviors")
	%list.add_item(name, Utils.icon_from_theme(behaviors[name], anchor) if name in behaviors else Utils.icon_for_class(name, anchor), false)

func _gui_input(event):
	if event is InputEventKey and event.pressed:
		match event.keycode:
			KEY_DOWN: move_focus(1)
			KEY_UP: move_focus(-1)
			KEY_ENTER:
				selected(get_focused_index())

func get_focused_index():
	var l = %list.get_selected_items()
	return l[0] if not l.is_empty() else -1

func selected(index: int):
	%list.visible = false
	text = %list.get_item_text(index)
	find_next_valid_focus().grab_focus()
	method_selected.emit(text)

func move_focus(dir: int):
	var current = get_focused_index() + dir
	while current < %list.item_count and current >= 0 and not %list.is_item_selectable(current):
		current += dir
	%list.select(clamp(current, 0, %list.item_count - 1))
	%list.ensure_current_is_visible()

func _ready():
	text_changed.connect(build_list)
	focus_exited.connect(func ():
		await get_tree().process_frame
		%list.visible = false)
	focus_entered.connect(func ():
		await get_tree().process_frame
		build_list(""))

func build_list(filter: String):
	assert(anchor != null)
	
	%list.clear()
	
	if not %list.visible:
		%list.visible = true
		%list.global_position = global_position + Vector2(0, get_rect().size.y)
	
	if node.get_script():
		add_class_item(node.get_script().resource_path.get_file().split('.')[0])
		for s in node.get_script().get_script_method_list():
			if s["name"].begins_with(filter) and s["name"][0] != "_": %list.add_item(s["name"])
	for c in Utils.all_classes_of(node):
		add_class_item(c)
		for s in ClassDB.class_get_method_list(c, true):
			if s["name"].begins_with(filter) and s["name"][0] != "_": %list.add_item(s["name"])
	
	if get_focused_index() == -1:
		move_focus(1)

func _on_list_pressed(index):
	if %list.is_item_selectable(index):
		selected(index)
