@tool
extends LineEdit

var node
var anchor

signal method_selected(name: String)

func add_class_item(name):
	%list.add_icon_item(Utils.icon_for_class(name, anchor), name)
	%list.set_item_disabled(%list.item_count - 1, true)

func _gui_input(event):
	if event is InputEventKey and event.pressed:
		match event.keycode:
			KEY_DOWN: move_focus(1)
			KEY_UP: move_focus(-1)
			KEY_ENTER:
				text = %list.get_item_text(%list.get_focused_item())
				find_next_valid_focus().grab_focus()
				method_selected.emit(text)

func move_focus(dir: int):
	var current = %list.get_focused_item() + dir
	while current < %list.item_count and current >= 0 and %list.is_item_disabled(current):
		current += dir
	%list.set_focused_item(clamp(current, 0, %list.item_count - 1))

func _ready():
	%list.exclusive = false
	%list.popup_window = false
	text_changed.connect(build_list)
	focus_exited.connect(func (): %list.hide())
	focus_entered.connect(func ():
		await get_tree().process_frame
		build_list(""))

func build_list(filter: String):
	%list.clear()
	
	if not %list.visible:
		%list.position = get_window().position + Vector2i(global_position) + Vector2i(0, get_rect().size.y)
		%list.show()
		# %list.popup_on_parent(Rect2i(global_position.x, global_position.y + get_rect().size.y, 200, 300))
		get_window().grab_focus()
		grab_focus()
	
	if node.get_script():
		add_class_item(node.get_script().resource_path.get_file())
		for s in node.get_script().get_script_method_list():
			if s["name"].begins_with(filter): %list.add_item(s["name"])
	for c in Utils.all_classes_of(node):
		add_class_item(c)
		for s in ClassDB.class_get_method_list(c, true):
			if s["name"].begins_with(filter): %list.add_item(s["name"])
