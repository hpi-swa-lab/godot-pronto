@tool
extends Node2D
class_name Behavior

var _icon
var _handles := Handles.new()
var _lines := Lines.new()
var _cached_pos = []

func _ready():
	if Engine.is_editor_hint() and show_icon() and is_active_scene():
		_icon = TextureRect.new()
		var name = get_script().resource_path.get_file().split('.')[0]
		_icon.texture = Utils.icon_from_theme(G.at("_pronto_behaviors")[name], self)
		_icon.position = _icon.texture.get_size() / -2
		add_child(_icon, false, Node.INTERNAL_MODE_FRONT)

func is_active_scene() -> bool:
	return owner == null or get_editor_plugin().get_editor_interface().get_edited_scene_root() == owner

func get_editor_plugin() -> EditorPlugin:
	return G.at("_pronto_editor_plugin")

func show_icon():
	return true

func connect_ui():
	return null

func _process(delta):
	var current_pos = Connection.get_connections(self).map(func (connection):
		if connection.expression:
			return global_position
		var other = get_node_or_null(connection.to)
		if other:
			return other.global_position
		return Vector2.ZERO)
	current_pos.append(global_position)
	
	if current_pos != _cached_pos:
		queue_redraw()
		_cached_pos = current_pos

func _forward_canvas_draw_over_viewport(viewport_control: Control):
	_handles._forward_canvas_draw_over_viewport(self, viewport_control)

func _forward_canvas_gui_input(event: InputEvent, undo_redo: EditorUndoRedoManager):
	return _handles._forward_canvas_gui_input(self, event, undo_redo)

func deselected():
	_handles.deselected()

func handles():
	return []

func lines():
	var lines := {}
	var self_connected := []
	
	for connection in Connection.get_connections(self):
		if connection.expression:
			self_connected.append(connection)
			continue
		var other = get_node_or_null(connection.to)
		if not other:
			continue
		if not other in lines:
			lines[other] = []
		lines[other].append(connection)
	
	var l = lines.keys().map(func (other):
		return Lines.Line.new(self, other, func (flip):
			return '\n'.join(lines[other].map(func(connection): return _print_connection(connection, flip))))
		)
	var s = self_connected.map(func (connection):
		return Lines.Line.new(self, self, func (flip): return _print_connection(connection, flip)))
	l.append_array(s)
	return l

func _draw():
	if not Engine.is_editor_hint() or not _icon:
		return
	_lines._draw_lines(self, lines())

func _print_connection(connection: Connection, flip = false):
	var prefix = "[?] " if connection.has_condition() else ""
	if connection.invoke != "":
		return ("{2}{1} ← {0}" if flip else "{0} → {1}").format([connection.signal_name, connection.invoke, prefix])
	else:
		return "{2}{0} ↺ {1}...".format([connection.signal_name, connection.expression.substr(0, 5), prefix])
