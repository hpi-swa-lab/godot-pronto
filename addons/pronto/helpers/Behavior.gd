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
		
		# spawn slightly offset from parent
		if position == Vector2.ZERO:
			position = Vector2(0, 30).rotated(get_parent().get_child_count() * PI / 4)

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
	# FIXME not scheduling well yet on fast repeats
	var current = _running_tweens.get(c)
	if current != null and not current.is_running(): current = null
	if current != null:
		if current.get_total_elapsed_time() < 0.1:
			return
		else:
			current.kill()
	var t = create_tween()
	_running_tweens[c] = t
	if current == null:
		t.tween_method(flash_line.bind(c), 0.0, 1.0, 0.2)
	t.tween_method(flash_line.bind(c), 1.0, 0.0, 0.2)
	
# duplicating as Godot does not support overloading
# see: https://github.com/godotengine/godot-proposals/issues/1571
var _running_highlight_tweens = {}
func highlight_activated(c: Connection):
	# FOR LATER: use different color for highlight and activation
	var duration = 0.3
	# FIXME not scheduling well yet on fast repeats
	var current = _running_highlight_tweens.get(c)
	if current != null and not current.is_running(): current = null
	if current != null:
		current.kill()
	var t = create_tween()
	_running_highlight_tweens[c] = t
	t.tween_method(flash_line.bind(c), 1.0, 0.0, duration)

func flash_line(value: float, key: Variant):
	_lines.flash_line(value, key)
	queue_redraw()

func lines() -> Array:
	return Connection.get_connections(self).map(func (connection):
		var other = self if not connection.is_target() else get_node_or_null(connection.to)
		if other == null:
			return null
		connection.changed_enabled.connect(func(new_state): 
			_lines.set_enabled(new_state, connection)
			queue_redraw()
		)
		return Lines.Line.new(self, other, func (flipped): return connection.print(flipped), connection)
	)

func _draw():
	if not Engine.is_editor_hint() or not _icon or not is_inside_tree():
		return
	_lines._draw_lines(self, lines())
