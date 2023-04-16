@tool
extends TextureRect
class_name Behavior

func _ready():
	Utils.setup(self)
	item_rect_changed.connect(queue_redraw)

func _draw():
	if not Engine.is_editor_hint():
		return
	
	var default_font := ThemeDB.fallback_font
	var text_size = 4
	
	var lines = {}
	var self_connected = []
	
	for connection in get_meta("pronto_connections", []):
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
		var begin = Vector2.ZERO + size / 2.0
		var end = Utils.global_rect_of(other).get_center() - get_global_rect().position
		draw_line(begin, end, Color.WHITE, lerp(0.02, 1.0, 1.0 / get_viewport_transform().get_scale().x), true)
		
		var angle = begin.angle_to_point(end)
		var flip = Utils.between(angle, PI / 2, PI) or Utils.between(angle, -PI, -PI / 2)
		
		var text = '\n'.join(lines[other].map(func(connection): return ("{1} ← {0}" if flip else "{0} → {1}").format([connection.signal_name, connection.invoke])))
		
		draw_set_transform(size / 2, angle + PI if flip else angle)
		draw_multiline_string(default_font,
			Vector2(-default_font.get_multiline_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, text_size).x - 12, -2) if flip else Vector2(12, -2),
			text,
			HORIZONTAL_ALIGNMENT_LEFT, -1, text_size, -1, Color.WHITE)
	
	if not self_connected.is_empty():
		draw_set_transform(Vector2.ZERO)
		var text = '\n'.join(self_connected.map(func(connection): return "{0} ↺ {1}...".format([connection.signal_name, connection.expression.substr(0, 5)])))
		var r = Utils.global_rect_of(self)
		draw_multiline_string(default_font,
			Vector2(0, r.size.y + text_size),
			text,
			HORIZONTAL_ALIGNMENT_LEFT, -1, text_size, -1, Color.WHITE)
