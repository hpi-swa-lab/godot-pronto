@tool
extends Node
class_name Lines

var _last_zoom = 1.0
var _lines: Array[Line] = []

func remove_all_that(cond: Callable):
	_lines = _lines.filter(func (n): return not cond.call(n))

func add_line(line: Line):
	_lines.append(line)

func remove_line(key: Variant):
	remove_all_that(func (c): return c.has_key(key))

func _needs_update(node: Behavior):
	var new_zoom = _lines[0].from.get_viewport_transform().get_scale().x if not _lines.is_empty() else 1.0
	var needs_update = _last_zoom != new_zoom
	_last_zoom = new_zoom
	return needs_update or _lines.any(func(l): return l.needs_update(node))

func _draw_lines(c: Behavior):
		var text_size = 4
		var font = ThemeDB.fallback_font
		
		var groups = Utils.group_by(_lines, func (l): return l.to)
		for to in groups:
			var lines = groups[to]
			if to == lines[0].from:
				c.draw_set_transform(Vector2.ZERO)
				var text = '\n'.join(lines.map(func(line: Line): return c.text_for_line(line, false)))
				c.draw_multiline_string(font,
					Vector2(0, c._icon.get_size().y / 2 + text_size),
					text,
					HORIZONTAL_ALIGNMENT_LEFT, -1, text_size, -1, Color.WHITE)
			else:
				if lines.size() > 1:
					lines[0].as_combined(lines)._draw(c, font, text_size)
				else:
					lines[0]._draw(c, font, text_size)

class Line:
	var from: Node
	var to: Node
	var key: Variant

	var _last_from
	var _last_to
	var _last_text
	
	func _init(from: Node, to: Node, key: Variant):
		self.from = from
		self.to = to
		self.key = key
	
	func as_combined(lines):
		var c = CombinedLine.new(from, to, key)
		c.lines = lines
		return c
	
	func has_key(key: Variant):
		return typeof(key) == typeof(self.key) and key == self.key
	
	func needs_update(node: Behavior):
		var new_text = node.text_for_line(self, false)
		var update = _last_from != from.global_position or _last_to != to.global_position or new_text != _last_text
		_last_from = from.global_position
		_last_to = to.global_position
		_last_text = new_text
		return update
	
	func draw_line(c: Behavior, begin: Vector2, end: Vector2, color: Color, width: float):
		c.draw_line(begin, end, color, width, true)
	
	func text_for_line(c: Behavior, flipped: bool):
		return c.text_for_line(self, flipped)
	
	func _draw(c: Behavior, font: Font, text_size: int):
		if from == to:
			return
		
		c.draw_set_transform(Vector2.ZERO)
		
		var begin = Vector2.ZERO
		var end = Utils.global_rect_of(to).get_center() - from.global_position
		draw_line(c, begin, end, Color.WHITE, lerp(0.02, 1.0, 1.0 / from.get_viewport_transform().get_scale().x))
		
		var angle = begin.angle_to_point(end)
		var flip = Utils.between(angle, PI / 2, PI) or Utils.between(angle, -PI, -PI / 2)
		
		var text = text_for_line(c, flip)
		if text != "":
			c.draw_set_transform(Vector2.ZERO, angle + PI if flip else angle)
			c.draw_multiline_string(font,
				Vector2(-font.get_multiline_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, text_size).x - 12, -2) if flip else Vector2(12, -2),
				text,
				HORIZONTAL_ALIGNMENT_LEFT, -1, text_size, -1, Color.WHITE)

class CombinedLine extends Line:
	var lines
	func text_for_line(c: Behavior, flipped: bool):
		return "\n".join(lines.map(func (line): return c.text_for_line(line, flipped)))

class DashedLine extends Line:
	func draw_line(c: Behavior, begin: Vector2, end: Vector2, color: Color, width: float):
		c.draw_dashed_line(begin, end, color, width * 2, 2.0)
