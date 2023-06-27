@tool
extends EditorPlugin
class_name Pronto

var edited_object
var popup
var behaviors = {}
var debugger: ConnectionDebug
var inspectors = [ExpressionInspector.new()]

func _enter_tree():
	if not Engine.is_editor_hint():
		return
	
	var regex = RegEx.new()
	regex.compile("#thumb\\(\"(.+)\"\\)")
	var base = get_editor_interface().get_base_control()
	
	for file in DirAccess.get_files_at("res://addons/pronto/behaviors"):
		var name = file.get_basename()
		var icon = ""
		var script = load("res://addons/pronto/behaviors/" + file)
		var result = regex.search(script.source_code)
		if result:
			icon = result.strings[1]
		else:
			push_error("Behavior {0} is missing #thumb(\"...\") annotation".format([name]))
		add_custom_type(name, "Node2D", script,	base.get_theme_icon(icon, &"EditorIcons"))
		behaviors[name] = icon
	G.put("_pronto_behaviors", behaviors)
	G.put("_pronto_editor_plugin", self)
	
	debugger = ConnectionDebug.new(get_editor_interface())
	add_debugger_plugin(debugger)
	for i in inspectors: add_inspector_plugin(i)
	
	get_undo_redo().history_changed.connect(history_changed)

func history_changed():
	if _is_editing_behavior() and edited_object is Placeholder and edited_object.should_keep_in_origin():
		var u = get_undo_redo().get_history_undo_redo(get_undo_redo().get_object_history_id(edited_object))
		if edited_object.position != Vector2.ZERO:
			var p = edited_object.get_parent()
			var t = edited_object.global_transform
			# undo the Placeholder's move and instead move the parent
			u.undo()
			u.create_action("Move parent of Placeholder")
			u.add_undo_property(p, "global_transform", p.global_transform)
			u.add_do_property(edited_object.get_parent(), "global_transform", t)
			u.commit_action()
			edited_object.position = Vector2.ZERO

func _exit_tree():
	for key in behaviors:
		remove_custom_type(key)
	behaviors.clear()
	remove_debugger_plugin(debugger)
	for i in inspectors: remove_inspector_plugin(i)

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
	if _is_editing_behavior() and edited_object.has_method("deselected"):
		edited_object.deselected()
	
	# get_editor_interface().edit_script(load("res://examples/platformer.tscn::GDScript_tb7ap"))
	
	edited_object = object
	if _is_editing_behavior() and edited_object is Node:
		show_signals(edited_object)
	else:
		close()

func close():
	if popup and is_instance_valid(popup): popup.queue_free()
	popup = null

func _make_visible(visible):
	if not visible:
		close()
	edited_object = null

func _forward_canvas_gui_input(event):
	if not _is_editing_behavior():
		return false
	if not edited_object.has_method("_forward_canvas_gui_input"):
		return false
	var ret = edited_object._forward_canvas_gui_input(event, get_undo_redo())
	if ret:
		update_overlays()
	return ret

func _forward_canvas_draw_over_viewport(viewport_control):#
	if _is_editing_behavior() and edited_object.has_method("_forward_canvas_draw_over_viewport"):
		return edited_object._forward_canvas_draw_over_viewport(viewport_control)

func _is_editing_behavior():
	if not is_instance_valid(edited_object):
		# edited_object might be freed after inspecting an object from a prior debugging session
		return false
	return edited_object

func show_signals(node: Node):
	if popup:
		close()
	
	var Connect = preload("res://addons/pronto/signal_connecting/connect.tscn")
	popup = Connect.instantiate()
	popup.undo_redo = get_undo_redo()
	popup.node = node
	popup.anchor = Utils.parent_that(node, func (p): return Utils.has_position(p))
	Utils.spawn_popup_from_canvas(node, popup)

func _valid_drop_for_slider(data):
	if not data is Dictionary or data["type"] != "obj_property" or not data["object"] is Node:
		return false
	var current = data["object"].get(data["property"])
	return current is int or current is float

var _drop_popup
func _notification(what):
	if what == NOTIFICATION_DRAG_BEGIN:
		var data = get_viewport().gui_get_drag_data()
		if _valid_drop_for_slider(data):
			_drop_popup = Value.DropPropertyPrompt.new(get_editor_interface())
			var scene = get_editor_interface().get_edited_scene_root()
			Utils.spawn_popup_from_canvas(scene, _drop_popup)
			var anchor = scene.get_viewport().get_parent().get_parent()
			_drop_popup.position = anchor.global_position + anchor.size / 2
	if what == NOTIFICATION_DRAG_END and _drop_popup:
		_drop_popup.queue_free()
		_drop_popup = null
