@tool
extends Node
class_name Lines

var _last_pos = []
var _last_zoom = 1.0
var _flashed = {}

func flash_line(value: float, key: Variant):
	_flashed[key] = value

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
	return needs_update

func _draw_lines(c: CanvasItem, lines: Array):
	var text_size = 4
	var font = ThemeDB.fallback_font
	
	var groups = Utils.group_by(lines, func (l): return l.to)
	for to in groups:
		var group = groups[to]
		if to == group[0].from:
			c.draw_set_transform(Vector2.ZERO)
			var text = '\n'.join(group.map(func(line: Line): return line.text(false)))
			c.draw_multiline_string(font,
				Vector2(0, c._icon.get_size().y / 2 + text_size),
				text,
				HORIZONTAL_ALIGNMENT_LEFT, -1, text_size, -1, Color.WHITE)
		else:
			if group.size() > 1:
				group[0].as_combined(group)._draw(c, font, text_size)
			else:
				group[0]._draw(c, font, text_size)

class Line:
	var text_fn: Callable
	var from: Node
	var to: Node
	var key: Variant
	
	func _init(from: Node, to: Node, text_fn: Callable, key: Variant):
		self.text_fn = text_fn
		self.from = from
		self.to = to
		self.key = key
	
	func as_combined(lines):
		var c = CombinedLine.new(from, to, func(f): return "", key)
		c.lines = lines
		return c
	
	func text(flipped: bool):
		return text_fn.call(flipped)
	
	func draw_line(c: CanvasItem, begin: Vector2, end: Vector2, color: Color, width: float):
		c.draw_line(begin, end, color, width, true)
	
	func _draw(c: CanvasItem, font: Font, text_size: int):
		if from == to:
			return
		
		c.draw_set_transform(Vector2.ZERO)
		
		var begin = Vector2.ZERO
		var end = Utils.global_rect_of(to).get_center() - from.global_position
		draw_line(c, begin, end, Color.WHITE, lerp(0.02, 1.0, 1.0 / from.get_viewport_transform().get_scale().x))
		
		var angle = begin.angle_to_point(end)
		var flip = Utils.between(angle, PI / 2, PI) or Utils.between(angle, -PI, -PI / 2)
		
		var text = text(flip)
		if text != "":
			c.draw_set_transform(Vector2.ZERO, angle + PI if flip else angle)
			c.draw_multiline_string(font,
				Vector2(-font.get_multiline_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, text_size).x - 12, -2) if flip else Vector2(12, -2),
				text,
				HORIZONTAL_ALIGNMENT_LEFT, -1, text_size, -1, Color.WHITE)

class DashedLine extends Line:
	func draw_line(c: CanvasItem, begin: Vector2, end: Vector2, color: Color, width: float):
		c.draw_dashed_line(begin, end, color, width * 2, 2.0)

class CombinedLine extends Line:
	var lines
	func text(flipped: bool):
		return "\n".join(lines.map(func (line): return line.text(flipped)))
