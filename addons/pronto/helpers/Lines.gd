@tool
extends Node
class_name Lines

var _last_pos = []
var _last_zoom = 1.0

func _needs_update(lines: Array):
	var new_zoom = lines[0].from.get_viewport_transform().get_scale().x if not lines.is_empty() else 1.0
	var needs_update = _last_zoom != new_zoom
	_last_zoom = new_zoom
	
	var new_pos = []
	for l in lines:
		new_pos.append(l.from.global_position)
		new_pos.append(l.to.global_position)
		new_pos.append(l.text_fn.call(false))
	needs_update = needs_update or _last_pos != new_pos
	_last_pos = new_pos
	if name == "Clock":
		print(needs_update)
	return needs_update

func _draw_lines(c: CanvasItem, lines: Array):
		var text_size = 4
		var font = ThemeDB.fallback_font
		
		for line in lines: line._draw(c, font, text_size)
		
		var self_connected = lines.filter(func (l): return l.from == l.to)
		if not self_connected.is_empty():
			c.draw_set_transform(Vector2.ZERO)
			var text = '\n'.join(self_connected.map(func(line: Line): return line.text_fn.call(false)))
			c.draw_multiline_string(font,
				Vector2(0, c._icon.get_size().y / 2 + text_size),
				text,
				HORIZONTAL_ALIGNMENT_LEFT, -1, text_size, -1, Color.WHITE)

class Line:
	var text_fn: Callable
	var from: Node
	var to: Node
	
	func _init(from: Node, to: Node, text_fn: Callable):
		self.text_fn = text_fn
		self.from = from
		self.to = to
	
	func _draw(c: CanvasItem, font: Font, text_size: int):
		if from == to:
			return
		
		c.draw_set_transform(Vector2.ZERO)
		
		var begin = Vector2.ZERO
		var end = Utils.global_rect_of(to).get_center() - from.global_position
		c.draw_line(begin, end, Color.WHITE, lerp(0.02, 1.0, 1.0 / from.get_viewport_transform().get_scale().x), true)
		
		var angle = begin.angle_to_point(end)
		var flip = Utils.between(angle, PI / 2, PI) or Utils.between(angle, -PI, -PI / 2)
		
		var text = text_fn.call(flip)
		if text != "":
			c.draw_set_transform(Vector2.ZERO, angle + PI if flip else angle)
			c.draw_multiline_string(font,
				Vector2(-font.get_multiline_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, text_size).x - 12, -2) if flip else Vector2(12, -2),
				text,
				HORIZONTAL_ALIGNMENT_LEFT, -1, text_size, -1, Color.WHITE)
