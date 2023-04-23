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
		var combined = group[0].as_combined(group)
		if to == group[0].from:
			c.draw_set_transform(Vector2(0, c._icon.get_size().y / 2 + text_size))
			combined.draw_text(c, font, text_size, false, _flashed)
		else:
			combined._draw(c, font, text_size, _flashed)

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
		if lines.size() == 1:
			return lines[0]
		var c = CombinedLine.new(from, to, func(f): return "", key)
		c.lines = lines
		return c
	
	func color(flashed: Dictionary):
		return Color.WHITE.lerp(Color.RED, flashed.get(key, 0.0))
	
	func draw_text(c: CanvasItem, font: Font, text_size: int, flipped: bool, flashed: Dictionary):
		var text = text_fn.call(flipped)
		var size = font.get_multiline_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, text_size)
		c.draw_multiline_string(font,
			Vector2(-size.x - 24, 0) if flipped else Vector2(0, 0),
			text,
			HORIZONTAL_ALIGNMENT_LEFT, -1, text_size, -1, color(flashed))
	
	func draw_line(c: CanvasItem, begin: Vector2, end: Vector2, color: Color, width: float):
		c.draw_line(begin, end, color, width, true)
	
	func _draw(c: CanvasItem, font: Font, text_size: int, flashed: Dictionary):
		if from == to:
			return
		
		c.draw_set_transform(Vector2.ZERO)
		
		var begin = Vector2.ZERO
		var end = Utils.global_rect_of(to).get_center() - from.global_position
		draw_line(c, begin, end, color(flashed), lerp(0.02, 1.0, 1.0 / from.get_viewport_transform().get_scale().x))
		
		var angle = begin.angle_to_point(end)
		var flip = Utils.between(angle, PI / 2, PI) or Utils.between(angle, -PI, -PI / 2)
		
		c.draw_set_transform_matrix(Transform2D(angle + PI if flip else angle, Vector2.ZERO) * Transform2D(0.0, Vector2(12, -2)))
		draw_text(c, font, text_size, flip, flashed)

class DashedLine extends Line:
	func draw_line(c: CanvasItem, begin: Vector2, end: Vector2, color: Color, width: float):
		c.draw_dashed_line(begin, end, color, width * 2, 2.0)

class CombinedLine extends Line:
	var lines
	func draw_text(c: CanvasItem, font: Font, text_size: int, flipped: bool, flashed: Dictionary):
		var y = 0
		for line in lines:
			var text = line.text_fn.call(flipped)
			var color = line.color(flashed)
			var size = font.get_multiline_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, text_size)
			c.draw_multiline_string(font,
				Vector2(-size.x - 24, y) if flipped else Vector2(0, y),
				text,
				HORIZONTAL_ALIGNMENT_LEFT, -1, text_size, -1, color)
			y += size.y
