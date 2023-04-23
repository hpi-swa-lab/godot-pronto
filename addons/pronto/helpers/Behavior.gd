@tool
extends Node2D
class_name Behavior

var _icon
var _handles := Handles.new()
var _lines := Lines.new()

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
	if _lines._needs_update(lines()):
		queue_redraw()

func _forward_canvas_draw_over_viewport(viewport_control: Control):
	_handles._forward_canvas_draw_over_viewport(self, viewport_control)

func _forward_canvas_gui_input(event: InputEvent, undo_redo: EditorUndoRedoManager):
	return _handles._forward_canvas_gui_input(self, event, undo_redo)

func deselected():
	_handles.deselected()

func handles():
	return []

var _running_tweens = {}
func connection_activated(c: Connection):
	var current = _running_tweens.get(c)
	if current != null: current.kill()
	
	var t = create_tween()
	_running_tweens[c] = t
	if current == null:
		t.tween_method(flash_line.bind(c), 0.0, 1.0, 0.2)
	t.tween_method(flash_line.bind(c), 1.0, 0.0, 0.2)

func flash_line(value: float, key: Variant):
	_lines.flash_line(value, key)
	queue_redraw()

func lines():
	return Connection.get_connections(self).map(func (connection):
		if connection.is_expression():
			return Lines.Line.new(self, self, func (flipped): return Utils.print_connection(connection, flipped), connection)
		else:
			var other = get_node_or_null(connection.to)
			if not other: return null
			return Lines.Line.new(self, other, func (flipped): return Utils.print_connection(connection, flipped), connection))

func _draw():
	if not Engine.is_editor_hint() or not _icon:
		return
	_lines._draw_lines(self, lines())
