@tool
extends EditorPlugin

var edited_object
var popup

func _enter_tree():
	if not Engine.is_editor_hint():
		return
	
	var base = get_editor_interface().get_base_control()
	add_custom_type("Move", "Node", preload("Move.gd"), base.get_theme_icon("ToolMove"))
	add_custom_type("Spawner", "TextureRect", preload("Spawner.gd"), base.get_theme_icon("GPUParticles3D", &"EditorIcons"))
	add_custom_type("Controls", "Node", preload("Controls.gd"), base.get_theme_icon("Shortcut"))
	add_custom_type("Bind", "Node", preload("Bind.gd"), base.get_theme_icon("Shortcut"))
	add_custom_type("State", "Node", preload("State.gd"), base.get_theme_icon("Shortcut"))
	add_custom_type("Collision", "TextureRect", preload("Collision.gd"), preload("res://addons/prototyping/icons/Collision.svg"))
	add_custom_type("Invoker", "Node", preload("Invoker.gd"), base.get_theme_icon("Shortcut"))
	add_custom_type("Clock", "TextureRect", preload("Clock.gd"), base.get_theme_icon("Timer", &"EditorIcons"))

func _exit_tree():
	remove_custom_type("Move")
	remove_custom_type("Spawner")
	remove_custom_type("Controls")
	remove_custom_type("Bind")
	remove_custom_type("State")
	remove_custom_type("Collision")
	remove_custom_type("Invoker")
	remove_custom_type("Clock")

func pronto_should_ignore(object):
	if not object is Node:
		return false
	
	if object.has_meta("pronto_ignore"):
		return object.get_meta("pronto_ignore")
	else:
		if object.has_method("get_parent") and object.get_parent():
			return pronto_should_ignore(object.get_parent())
		else:
			return false

func _handles(object):
	return !pronto_should_ignore(object)

func _edit(object):
	edited_object = object
	if edited_object and edited_object is Node:
		show_signals(edited_object)
	else:
		close()

func close():
	if popup: popup.queue_free()
	popup = null

func _make_visible(visible):
	if not visible:
		close()

func _forward_canvas_gui_input(event):
	var captured_event = false
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.is_pressed():
			# current_object = get_selection().get_selected_nodes()[0]
			captured_event = true
	return false

func show_signals(node: Node):
	if popup:
		close()
	
	var Connect = load("res://addons/prototyping/signal_connecting/connect.tscn")
	popup = Connect.instantiate()
	popup.node = node
	popup.anchor = Utils.parent_that(node, func (p): return Utils.has_position(p))
	Utils.spawn_popup_from_canvas(node, popup)
