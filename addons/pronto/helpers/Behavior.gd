@tool
extends Node2D
class_name Behavior

var _icon
var _handles := Handles.new()
var _lines := Lines.new()

## Given a line, return a label for that line. If [param flipped] is true, the
## label has been placed on the other side of the line.
func text_for_line(line: Lines.Line, flipped: bool):
	if line.key is Connection:
		return Utils.print_connection(line.key, flipped)
	return str(line.key)

func add_line(line: Lines.Line):
	# can only have one line with the same key -- convenient for overriding a line
	remove_line(line.key)
	_lines.add_line(line)

func remove_line(key: Variant):
	_lines.remove_line(key)

func _ready():
	if Engine.is_editor_hint() and show_icon() and is_active_scene():
		_icon = TextureRect.new()
		var name = get_script().resource_path.get_file().split('.')[0]
		_icon.texture = Utils.icon_from_theme(G.at("_pronto_behaviors")[name], self)
		_icon.position = _icon.texture.get_size() / -2
		add_child(_icon, false, Node.INTERNAL_MODE_FRONT)

func _enter_tree():
	ConnectionsList.connections_changed.connect(_check_connections)
	_check_connections(self)

func _exit_tree():
	ConnectionsList.connections_changed.disconnect(_check_connections)

func _check_connections(from: Node):
	if from != self:
		return
	
	_lines.remove_all_that(func (n): n.key is Connection)
	
	for connection in Connection.get_connections(self):
		if connection.is_expression():
			add_line(Lines.Line.new(self, self, connection))
		else:
			var other = get_node_or_null(connection.to)
			if not other: continue
			add_line(Lines.Line.new(self, other, connection))

func is_active_scene() -> bool:
	return owner == null or get_editor_plugin().get_editor_interface().get_edited_scene_root() == owner

func get_editor_plugin() -> EditorPlugin:
	return G.at("_pronto_editor_plugin")

func show_icon():
	return true

func connect_ui():
	return null

func _process(delta):
	if _lines._needs_update(self):
		queue_redraw()

func _forward_canvas_draw_over_viewport(viewport_control: Control):
	_handles._forward_canvas_draw_over_viewport(self, viewport_control)

func _forward_canvas_gui_input(event: InputEvent, undo_redo: EditorUndoRedoManager):
	return _handles._forward_canvas_gui_input(self, event, undo_redo)

func deselected():
	_handles.deselected()

func handles():
	return []

func connection_activated(c: Connection):
	# TODO visualize
	pass

func _draw():
	if not Engine.is_editor_hint() or not _icon:
		return
	_lines._draw_lines(self)
