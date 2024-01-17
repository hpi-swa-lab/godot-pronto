@tool
extends PanelContainer
class_name NodeToNodeConfigurator

static func _open(anchor: Node, undo_redo: EditorUndoRedoManager):
	var i = preload("res://addons/pronto/signal_connecting/node_to_node_configurator.tscn").instantiate()
	i.anchor = anchor
	i.undo_redo = undo_redo
	
	# FIXME godot 4.2 beta did not assign a background color to the panel
	var s = G.at("_pronto_editor_plugin").get_editor_interface().get_editor_settings()
	var box = StyleBoxFlat.new()
	box.bg_color = s.get("interface/theme/base_color")
	i.add_theme_stylebox_override("panel", box)
	
	return i

static func open_existing(undo_redo: EditorUndoRedoManager, from: Node, connection: Connection):
	var i = _open(Utils.parent_that(from, func (n): return Utils.has_position(n)), undo_redo)
	i.set_existing_connection(from, connection)
	return i.open(from)

static func open_new_invoke(undo_redo: EditorUndoRedoManager, from: Node, source_signal: Dictionary, receiver: Node):
	var i = _open(Utils.parent_that(receiver, func (n): return Utils.has_position(n)), undo_redo)
	i.selected_signal = source_signal
	i.from = from
	i.receiver = receiver
	i.set_mode(false, true)
	i.init_empty_scripts()
	return i.open(receiver)

static func open_new_expression(undo_redo: EditorUndoRedoManager, from: Node, source_signal: Dictionary):
	var i = _open(Utils.parent_that(from, func (n): return Utils.has_position(n)), undo_redo)
	i.selected_signal = source_signal
	i.from = from
	i.set_mode(true, false)
	i.init_empty_scripts()
	return i.open(from)

func open(receiver: Node):
	# find existing configurator siblings
	for configurator in Utils.popup_parent(receiver).get_children(true):
		if configurator is NodeToNodeConfigurator and configurator.has_same_connection(self):
			configurator.default_focus()
			return configurator
	
	Utils.spawn_popup_from_canvas(receiver, self)
	default_focus()
	return self

func has_same_connection(other: NodeToNodeConfigurator):
	return other.from == from \
		and other.selected_signal == selected_signal \
		and other.receiver == receiver \
		and other.existing_connection == existing_connection

var undo_redo: EditorUndoRedoManager

var anchor: Node:
	set(n):
		anchor = n
		reset_size()
		%FunctionName.anchor = n
var from: Node
var existing_connection = null

var selected_signal: Dictionary:
	set(value):
		selected_signal = value
		%Signal.text = value["name"]
		update_argument_names()

var position_offset = Vector2(0, 0)

var pinned = false:
	set(value):
		pinned = value
		%Pinned.button_pressed = value

func _input(event):
	if event is InputEventKey and event.keycode == KEY_ESCAPE and event.pressed:
		_on_cancel_pressed()
	if event is InputEventKey and (event.keycode == KEY_ENTER or event.keycode == KEY_KP_ENTER) and event.pressed and event.ctrl_pressed:
		_on_done_pressed()

var receiver: Object:
	set(value):
		receiver = value
		%ReceiverPath.text = "${0} ({1})".format([from.get_path_to(receiver), receiver.name])
		%FunctionName.anchor = anchor
		%FunctionName.node = receiver

var more_references: Array = []

func init_empty_scripts():
	%Expression.edit_script = empty_script("", false)
	%Condition.edit_script = empty_script("true", true)

func set_mode(expr: bool, recv: bool):
	%Expression.visible = expr
	%Receiver.visible = recv
	update_argument_names()
	if expr and %Expression.edit_script == null:
		%Expression.edit_script = empty_script("", false)
	mark_changed()

func default_focus():
	await get_tree().process_frame
	if %Expression.visible:
		%Expression.grab_focus()
	else:
		%FunctionName.grab_focus()

func use_vertical_arguments():
	return %Args.get_child_count() > 1

func update_argument_names():
	var names = argument_names()
	var types = argument_types()
	%Expression.argument_names = names
	%Expression.argument_types = types
	%Condition.argument_names = names
	%Condition.argument_types = types
	for c in %Args.get_children():
		c.argument_names = names
		c.argument_types = types
	%Args.vertical = use_vertical_arguments()
	
	%SignalArgs.text = "({0})".format([Utils.print_args(selected_signal)])
	
	for i in %BasicArgs.get_child_count():
		%BasicArgs.get_child(i).queue_free()
	var iref := -1
	for name in basic_argument_names():
		var label := Label.new()
		label.text = "{0}{1}".format([name, "," if name != basic_argument_names().back() else ""])
		%BasicArgs.add_child(label)
		
		label.mouse_filter = Control.MOUSE_FILTER_PASS
		var node_str
		if name == "from":
			node_str = from
		elif name == "receiver":
			node_str = receiver
		elif name.begins_with("ref"):
			iref += 1
			var ref = more_references[iref]
			node_str = "{0} ({1})".format([ref, from.get_node(ref)])
			
			# add popup menu for editing and removing reference
			label.mouse_filter = Control.MOUSE_FILTER_STOP
			label.gui_input.connect(func(event):
				if !(event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT and not event.pressed): return
				
				var menu := PopupMenu.new()
				menu.add_item("Edit path", 0)
				menu.add_item("Remove", 1)
				menu.id_pressed.connect(func(id):
					if id == 0:  # edit
						_request_reference_path(ref, func(new_ref):
							more_references[iref] = new_ref
							update_argument_names())
					elif id == 1:  # remove
						var new_more_references := []
						for i in range(more_references.size()):
							if i != iref:
								new_more_references.append(more_references[i])
						more_references = new_more_references
						update_argument_names()
				)
				label.add_child(menu)
				menu.size = Vector2.ZERO
				menu.position = label.global_position
				menu.popup()
			)
		
		label.tooltip_text = "{0}".format([node_str])
	
	# add deffered call to update size - HACKED
	(func():
		var tree = get_tree()
		if tree == null: return
		await tree.process_frame
		self.size = Vector2.ZERO
	).call_deferred()

func _ready():
	# adjust appearance (theme-aware!)
	if not Engine.is_editor_hint():  # don't override in editor, otherwise it will be saved to scene
		var stylebox = get_theme_stylebox("panel").duplicate()
		# set border width to 1 (theme-aware!)
		stylebox.set_border_width_all(1)
		# turn off background transparency
		var bg_color = stylebox.get_bg_color()
		bg_color.a = 0.9
		stylebox.set_bg_color(bg_color)
		add_theme_stylebox_override("panel", stylebox)

func _process(delta):
	if not anchor: return
	
	visible = anchor.is_inside_tree()
	if anchor.is_inside_tree():
		position = Utils.popup_position(anchor) + position_offset
		var offscreen_delta = (position + size - get_parent().size).clamp(Vector2(0, 0), Vector2(1000000, 1000000))
		position -= offscreen_delta
		%FunctionName.anchor = anchor

	var _parent = Utils.popup_parent(anchor)
	if not _parent: return
	var hovered_nodes = _parent.get_children(true).filter(func (n):
		if not (n is NodeToNodeConfigurator): return false
		return n.get_global_rect().has_point(get_viewport().get_mouse_position()))
	var is_hovered = hovered_nodes.size() > 0 and hovered_nodes[-1] == self
	if is_hovered:
		if self.existing_connection:
			Utils.get_behavior(from).highlight_activated(self.existing_connection)

func mark_changed(value: bool = true):
	%ChangesNotifier.visible = value

func set_existing_connection(from: Node, connection: Connection):
	self.from = from
	existing_connection = connection
	self.selected_signal = Utils.find(from.get_signal_list(), func (s): return s["name"] == connection.signal_name)
	set_mode(connection.is_expression(), connection.is_target())
	%Condition.edit_script = connection.only_if
	if connection.is_target():
		receiver = from.get_node(connection.to)
		%FunctionName.anchor = anchor
		%FunctionName.text = connection.invoke if not connection.is_expression() else "<statement(s)>"
		_on_function_selected(%FunctionName.text)
	for i in connection.more_references:
		more_references.append(i)
	update_argument_names()
	if connection.expression != null:
		%Expression.edit_script = connection.expression
	
	%Receiver.visible = connection.is_target()
	%Expression.visible = connection.is_expression()
	%Enabled.button_pressed = connection.enabled
	
	for i in range(%Args.get_child_count()):
		%Args.get_child(i).edit_script = connection.arguments[i] if i <= connection.arguments.size() - 1 else empty_script("null", true)
	
	# FIXME just increment total directly didn't work from the closure?!
	var total = {"total": 0}
	Utils.all_nodes_do(ConnectionsList.get_viewport(),
		func(n):
			total["total"] += Connection.get_connections(n).count(connection))
	%SharedLinksNote.visible = total["total"] > 1
	%SharedLinksCount.text = "This connection is linked to {0} other node{1}.".format([total["total"] - 1, "s" if total["total"] != 2 else ""])
	mark_changed(false)

func _on_function_selected(name: String):
	set_mode(name == "<statement(s)>", true)
	
	var cond = func (m): return m["name"] == name
	var method = null
	if receiver.get_script() != null:
		method = Utils.find(receiver.get_script().get_script_method_list(), cond)
	if method == null:
		method = Utils.find(receiver.get_method_list(), cond)
	
	for child in %Args.get_children():
		%Args.remove_child(child)
		child.queue_free()
	
	if method == null:
		return
	
	var ExpressionEdit = preload("res://addons/pronto/signal_connecting/expression_edit.tscn")
	
	var arguments = []
	if receiver is CodeBehavior and name == "execute":
		arguments = Array(receiver.arguments).map(func (argument_name): return {"name": argument_name})
	elif receiver is SceneRootBehavior and name.begins_with("apply"):
		# remove "from" argument so it does not appear in the connection window, 
		# which is automatically set later in Connection.gd::_trigger.
		arguments = method["args"]
		arguments.pop_back()
	else:
		arguments = method["args"]
		var index = method["args"].size() - method["default_args"].size()
		var default_arg_index = 0
		while index < method["args"].size():
			arguments[index]["default_value"] = method["default_args"][default_arg_index]
			default_arg_index+=1
			index+=1
	
	for arg in arguments:
		var arg_ui = ExpressionEdit.instantiate()
		arg_ui.expression_label = arg["name"] + ": " + Utils.get_type_name_from_arg(arg)
		Utils.fix_minimum_size(arg_ui)
		arg_ui.placeholder_text = arg["name"]
		if name.begins_with("apply") && arg["type"] == 25:
			if arg["name"] == "filter_func":
				arg_ui.edit_script = empty_script("func(from, node): return true", true)
			else:
				arg_ui.edit_script = empty_script("func(from, node): null", true)
		else:
			if arg.has("default_value"):
				var default_expr
				# Arrays and dictionaries are not stored in the Godot default args value lists
				match arg["type"]:
					TYPE_ARRAY: default_expr = "[]"
					TYPE_DICTIONARY: default_expr = "{}"
					_: default_expr = Utils.as_code_string(arg["default_value"])
				arg_ui.edit_script = empty_script(default_expr, true)
			else:
				arg_ui.edit_script = empty_script(arg["name"], true)
		%Args.add_child(arg_ui)
		%Args.custom_minimum_size = Vector2(400, 0) * Utils.hidpi_scale()
		arg_ui.text_changed.connect(func(): mark_changed())
		arg_ui.save_requested.connect(func(): save())
	update_argument_names()

func empty_script(expr: String, return_value: bool):
	var script := ConnectionScript.new(argument_names(), return_value, expr)
	script.argument_types = argument_types()
	return script

func argument_names():
	return argument_names_and_types().map(func (a): return a[0])

func argument_types():
	return argument_names_and_types().map(func (a): return a[1])

func argument_names_and_types():
	return selected_signal["args"].map(func (a):
		# TODO: use reflection to get type of signal arguments?
		return [a["name"], null]) \
		+ basic_argument_names_and_types()

func basic_argument_names():
	return basic_argument_names_and_types().map(func (a): return a[0])

func basic_argument_names_and_types():
	var names_and_types = []
	names_and_types.append(["from", Utils.get_specific_class_name(from)])
	if %Receiver.visible:
		names_and_types.append(["to", Utils.get_specific_class_name(receiver)])
	names_and_types += range(len(more_references)).map(func (i):
		var ref = more_references[i]
		var node = from.get_node(ref)
		return ["ref{0}".format([i]), Utils.get_specific_class_name(node)])
	return names_and_types

func save():
	%FunctionName.accept_selected()
	
	if not %Expression.visible:
		var args = %Args.get_children()
		var invoke = %FunctionName.text
		# TODO check if only_if and args can be parsed
		if invoke.length() == 0: return
		if existing_connection:
			Utils.commit_undoable(undo_redo, "Update condition of connection", existing_connection.only_if,
				{"source_code": %Condition.text}, "reload")
			for i in range(args.size()):
				Utils.commit_undoable(undo_redo, "Update argument {0} of connection".format([i]),
					args[i].edit_script,
					{"source_code": args[i].text}, "reload")
			Utils.commit_undoable(undo_redo,
				"Update connection {0}".format([selected_signal["name"]]),
				existing_connection,
				{
					"expression": null,
					"invoke": invoke,
					"signal_name": %Signal.text,
					"more_references": more_references,
					"arguments": args.map(func (a): return a.edit_script)
				})
		else:
			existing_connection = Connection.connect_target(
				from,
				selected_signal["name"],
				from.get_path_to(receiver),
				invoke,
				args.map(func (a): return a.updated_script(from, selected_signal["name"])),
				more_references,
				%Condition.updated_script(from, selected_signal["name"]), undo_redo
			)
	else:
		if existing_connection:
			Utils.commit_undoable(undo_redo, "Update condition of connection", existing_connection.only_if,
				{"source_code": %Condition.text}, "reload")
			if existing_connection.expression != null:
				Utils.commit_undoable(undo_redo, "Update expression of connection", existing_connection.expression,
					{"source_code": %Expression.text}, "reload")
			else:
				Utils.commit_undoable(undo_redo,
				"Set connection expression",
				existing_connection, {"expression": %Expression.updated_script(from, selected_signal["name"])})
			Utils.commit_undoable(undo_redo,
				"Update connection {0}".format([selected_signal["name"]]),
				existing_connection,
				{
					"signal_name": %Signal.text,
					"more_references": more_references
				})
		else:
			var to_path = from.get_path_to(receiver) if %Receiver.visible else ""
			existing_connection = Connection.connect_expr(from, selected_signal["name"], to_path,
				%Expression.updated_script(from, selected_signal["name"]),
				more_references,
				%Condition.updated_script(from, selected_signal["name"]), undo_redo)

	existing_connection.enabled = %Enabled.button_pressed
	# FIXME doesn't respect undo
	ConnectionsList.emit_connections_changed()
	mark_changed(false)

func _on_done_pressed():
	save()
	if not pinned:
		queue_free()

func _on_remove_pressed():
	if existing_connection:
		existing_connection.delete(from, undo_redo)
	queue_free()

func _on_cancel_pressed():
	queue_free()

func _on_make_unique_pressed():
	var duplicate = existing_connection.make_unique(from, undo_redo)
	queue_free()
	open_existing(undo_redo, from, duplicate)

var _drag_start_offset = null

func _on_gui_input(event: InputEvent):
	if event is InputEventMouseButton and event.double_click and event.button_index == MOUSE_BUTTON_LEFT:
		_double_click()
	elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.is_pressed():
			_start_drag(event.global_position)
		else:
			_stop_drag()
	elif event is InputEventMouseMotion and _drag_start_offset != null:
		_drag(event.global_position)

func _double_click():
	pinned = not pinned

func _start_drag(_position: Vector2):
	_drag_start_offset = _position - position_offset
	# come to front
	self.get_parent().move_child(self, -1)

func _stop_drag():
	_drag_start_offset = null

func _drag(_position: Vector2):
	position_offset = _position - _drag_start_offset

func _on_pinned_toggled(button_pressed):
	pinned = button_pressed

func _on_enabled_toggled(button_pressed):
	if existing_connection:
		existing_connection.enabled = button_pressed
	else:
		mark_changed()

func _on_add_reference_button_pressed():
	_request_reference_path(^"", func (path):
		more_references += [path]
		update_argument_names()
		mark_changed())

func _request_reference_path(path, callback: Callable):
	var dialog := AcceptDialog.new()
	dialog.set_title('Enter reference path (relative to "from")')
	var lineEdit := LineEdit.new()
	lineEdit.text = path
	dialog.add_child(lineEdit)
	dialog.add_cancel_button("Cancel")
	
	dialog.connect("confirmed", func():
		path = NodePath(lineEdit.text)
		dialog.queue_free()
		if !path.is_empty():
			callback.call(path))
	
	add_child(dialog)
	dialog.size = Vector2(420, 100)
	dialog.popup_centered()
