@tool
extends EditorPlugin
class_name Pronto

var edited_object

var popup
var behaviors = {}
var debugger: ConnectionDebug
var inspectors = [ExpressionInspector.new(), SpriteInspector.new(), StoreInspector.new()]

func _enter_tree():
	if not Engine.is_editor_hint():
		return
	
	PromoteUtil.install_menu_item(get_editor_interface())
	find_behavior_classes()
	
	G.put("_pronto_behaviors", behaviors)
	G.put("_pronto_editor_plugin", self)
	
	debugger = ConnectionDebug.new(get_editor_interface())
	add_debugger_plugin(debugger)
	for i in inspectors: add_inspector_plugin(i)
	
	get_undo_redo().history_changed.connect(_history_changed)
	scene_changed.connect(_initialize_scene)

func _exit_tree():
	for key in behaviors:
		remove_custom_type(key)
	behaviors.clear()
	remove_debugger_plugin(debugger)
	for i in inspectors: remove_inspector_plugin(i)
	get_undo_redo().history_changed.disconnect(_history_changed)
	scene_changed.disconnect(_initialize_scene)
	PromoteUtil.uninstall()

func _handles(object):
	return !pronto_should_ignore(object)

## If the passed object is a Behavior, return it.
## Otherwise, we create a Behavior as a hidden child that will now
## perform tasks such as drawing connections for that non-Behavior node.
static func get_behavior(object):
	if not object is Node: return null
	if object is Behavior: return object
	for child in object.get_children(true):
		if child is Behavior and child.hidden_child: return child
	var b = Behavior.new()
	b.hidden_child = true
	object.add_child(b, false, INTERNAL_MODE_FRONT)
	return b

func _edit(object):
	if object != edited_object:
		var old = get_behavior(edited_object)
		if old: old.deselected()

	edited_object = object

	var new = get_behavior(edited_object)
	if new:
		new.selected()
		show_signals(edited_object)
	else:
		close()

func _make_visible(visible):
	if visible:
		_edit(edited_object)
	else:
		_edit(null)

func _forward_canvas_gui_input(event):
	var behavior = get_behavior(edited_object)
	if not behavior: return false
	var ret = behavior._forward_canvas_gui_input(event, get_undo_redo())
	if ret: update_overlays()
	return ret

func _forward_canvas_draw_over_viewport(viewport_control):
	var behavior = get_behavior(edited_object)
	if behavior: behavior._forward_canvas_draw_over_viewport(viewport_control)

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
			_drop_popup = ValueBehavior.DropPropertyPrompt.new(get_editor_interface())
			var scene = get_editor_interface().get_edited_scene_root()
			Utils.spawn_popup_from_canvas(scene, _drop_popup)
			var anchor = scene.get_viewport().get_parent().get_parent()
			_drop_popup.position = anchor.global_position + anchor.size / 2
	if what == NOTIFICATION_DRAG_END and _drop_popup:
		_drop_popup.queue_free()
		_drop_popup = null

func close():
	if popup and is_instance_valid(popup): popup.queue_free()
	popup = null

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

func valid_instance(object):
	return is_instance_valid(object)

## Convenience that allows moving a placeholder (which has keep_in_origin set)
## but instead moves the parent, which is typically what you actually meant.
func _history_changed():
	if valid_instance(edited_object) and edited_object is PlaceholderBehavior and edited_object.should_keep_in_origin():
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

## List all behaviors in their folder and install as custom types
func find_behavior_classes():
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

## Ensure that we create hidden_child Behaviors for all nodes in a newly
## opened scene.
func _initialize_scene(scene):
	if not scene: return
	for node in scene.get_children():
		get_behavior(node)
		_initialize_scene(node)
