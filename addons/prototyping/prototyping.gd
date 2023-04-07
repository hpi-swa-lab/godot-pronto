@tool
extends EditorPlugin

var edited_object
var popup

func _enter_tree():
	if not Engine.is_editor_hint():
		return
	
	var base = get_editor_interface().get_base_control()
	add_custom_type("Move", "TextureRect", preload("Move.gd"), base.get_theme_icon("ToolMove", &"EditorIcons"))
	add_custom_type("Spawner", "TextureRect", preload("Spawner.gd"), base.get_theme_icon("GPUParticles3D", &"EditorIcons"))
	add_custom_type("Controls", "TextureRect", preload("Controls.gd"), base.get_theme_icon("Joypad", &"EditorIcons"))
	add_custom_type("Bind", "TextureRect", preload("Bind.gd"), base.get_theme_icon("EditBezier", &"EditorIcons"))
	add_custom_type("State", "TextureRect", preload("State.gd"), base.get_theme_icon("CylinderMesh", &"EditorIcons"))
	add_custom_type("Collision", "TextureRect", preload("Collision.gd"), base.get_theme_icon("GPUParticlesCollisionBox3D", &"EditorIcons"))
	add_custom_type("Clock", "TextureRect", preload("Clock.gd"), base.get_theme_icon("Timer", &"EditorIcons"))
	add_custom_type("Always", "TextureRect", preload("Always.gd"), base.get_theme_icon("Loop", &"EditorIcons"))

func _exit_tree():
	remove_custom_type("Move")
	remove_custom_type("Spawner")
	remove_custom_type("Controls")
	remove_custom_type("Bind")
	remove_custom_type("State")
	remove_custom_type("Collision")
	remove_custom_type("Clock")
	remove_custom_type("Always")

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
