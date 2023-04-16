@tool
extends Node2D
class_name Behavior

var _icon
var _cached_pos = []

func _ready():
	if Engine.is_editor_hint() and show_icon():
		_icon = TextureRect.new()
		var name = get_script().resource_path.get_file().split('.')[0]
		_icon.texture = Utils.icon_from_theme(Pronto.COMPONENTS[name], self)
		_icon.position = _icon.texture.get_size() / -2
		add_child(_icon, false, Node.INTERNAL_MODE_FRONT)

func show_icon():
	return true

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

class Handle:
	var position
	var icon
	var apply
	
	func _init(position: Vector2, icon: Texture, apply: Callable):
		self.position = position
		self.icon = icon
		self.apply = apply
	
	func rect_in(node: CanvasItem):
		return Rect2(
			node.get_viewport_transform() * node.get_canvas_transform() * (node.global_position + position) - icon.get_size() / 2,
			icon.get_size())

func _forward_canvas_draw_over_viewport(viewport_control: Control):
	for handle in handles():
		viewport_control.draw_texture(handle.icon, handle.rect_in(self).position)

var _dragging = null

func _forward_canvas_gui_input(event):
	if event is InputEventMouse:
		if _dragging != null:
			if event is InputEventMouseButton and not event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
				_dragging = null
				return true
			if event is InputEventMouseMotion:
				_dragging.apply.call(get_viewport().get_global_canvas_transform().affine_inverse() * event.position - global_position)
				return true
		if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			for handle in handles():
				if handle.rect_in(self).has_point(event.position):
					_dragging = handle
					return true
	return false

func handles():
	return []

func _draw():
	if not Engine.is_editor_hint():
		return
	
	var default_font := ThemeDB.fallback_font
	var text_size = 4
	
	var lines = {}
	var self_connected = []
	
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
	
	for other in lines:
		draw_set_transform(Vector2.ZERO)
		var begin = Vector2.ZERO
		var end = Utils.global_rect_of(other).get_center() - global_position
		draw_line(begin, end, Color.WHITE, lerp(0.02, 1.0, 1.0 / get_viewport_transform().get_scale().x), true)
		
		var angle = begin.angle_to_point(end)
		var flip = Utils.between(angle, PI / 2, PI) or Utils.between(angle, -PI, -PI / 2)
		
		var text = '\n'.join(lines[other].map(func(connection): return ("{1} ← {0}" if flip else "{0} → {1}").format([connection.signal_name, connection.invoke])))
		
		draw_set_transform(Vector2.ZERO, angle + PI if flip else angle)
		draw_multiline_string(default_font,
			Vector2(-default_font.get_multiline_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, text_size).x - 12, -2) if flip else Vector2(12, -2),
			text,
			HORIZONTAL_ALIGNMENT_LEFT, -1, text_size, -1, Color.WHITE)
	
	if not self_connected.is_empty():
		draw_set_transform(Vector2.ZERO)
		var text = '\n'.join(self_connected.map(func(connection): return "{0} ↺ {1}...".format([connection.signal_name, connection.expression.substr(0, 5)])))
		draw_multiline_string(default_font,
			Vector2(0, _icon.get_size().y / 2 + text_size),
			text,
			HORIZONTAL_ALIGNMENT_LEFT, -1, text_size, -1, Color.WHITE)
