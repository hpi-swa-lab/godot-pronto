@tool
extends EditorPlugin

var edited_object
var popup

func _enter_tree():
	if not Engine.is_editor_hint():
		return
	
	var base = get_editor_interface().get_base_control()
	add_custom_type("Move", "Node", preload("Move.gd"), base.get_theme_icon("ToolMove"))
	add_custom_type("Spawner", "Node2D", preload("Spawner.gd"), base.get_theme_icon("Shortcut"))
	add_custom_type("Controls", "Node", preload("Controls.gd"), base.get_theme_icon("Shortcut"))
	add_custom_type("Bind", "Node", preload("Bind.gd"), base.get_theme_icon("Shortcut"))
	add_custom_type("State", "Node", preload("State.gd"), base.get_theme_icon("Shortcut"))
	add_custom_type("Collision", "Node", preload("Collision.gd"), preload("res://addons/prototyping/icons/Collision.svg"))
	add_custom_type("Invoker", "Node", preload("Invoker.gd"), base.get_theme_icon("Shortcut"))

func _handles(object):
	return true

func _edit(object):
	edited_object = object
	if edited_object:
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

func show_signals(component: Node):
	if popup:
		close()
	
	popup = Panel.new()
	popup.custom_minimum_size = Vector2(200, 400)
	var container = VBoxContainer.new()
	container.add_theme_constant_override("separation", -10)
	for s in component.get_signal_list():
		container.add_child(PSignal.new(s, component))
	
	var scroll = ScrollContainer.new()
	scroll.set_anchors_preset(Control.PRESET_FULL_RECT)
	scroll.add_child(container)
	popup.add_child(scroll)
	
	component.get_viewport().get_parent().get_parent().get_parent().get_parent().get_parent().add_child(popup, false, Node.INTERNAL_MODE_BACK)
	
	var anchor = parentThat(component, func (p): return p is Node2D or p is Control)
	popup.position = anchor.get_viewport_transform() * anchor.global_position
	
	return popup

func parentThat(node: Node, cond: Callable):
	if cond.call(node):
		return node
	return parentThat(node.get_parent(), cond)
