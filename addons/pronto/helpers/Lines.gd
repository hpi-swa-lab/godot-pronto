@tool
extends Node
class_name Lines

var _last_pos = []
var _last_zoom = 1.0
var _flashed = {}

func flash_line(key: Variant, type: String, value: float):
	_flashed[[key, type]] = value

const flash_colors = {
	'activated': Color.RED,
	'highlight': Color.GREEN,
}

func _needs_update(lines: Array):
	var new_zoom = lines[0].from.get_viewport_transform().get_scale().x if not lines.is_empty() else 1.0
	var needs_update = _last_zoom != new_zoom
	_last_zoom = new_zoom
	
	var new_pos = []
	for l in lines:
		new_pos.append(l.from.global_position)
		new_pos.append(Utils.find_position(l.to))
		new_pos.append(l.text_fn.call(false))
		new_pos.append(l.color)
	
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
		if to == group[0].from: # draw connection to itself
			var y = 0 if not c._icon else c._icon.get_size().y / 2 # for behaviors without displayed icon use y = 0
			print(c)
			c.draw_set_transform(Vector2(0, y + text_size))
			combined.draw_text(c, font, text_size, false, self)
			c.draw_set_transform(Vector2.ZERO)
		else:
			combined._draw(c, font, text_size, self)

class Line:
	var text_fn: Callable
	var from: Node
	var to: Node
	var key: Variant
	var color: Color
	
	func _init(from: Node, to: Node, text_fn: Callable, key: Variant, color = Color.WHITE):
		self.text_fn = text_fn
		self.from = from
		self.to = to
		self.key = key
		self.color = color
	
	func as_combined(lines):
		if lines.size() == 1:
			return lines[0]
		var c = CombinedLine.new(from, to, func(f): return "", key)
		c.lines = lines
		return c
	
	func current_color(lines: Lines) -> Color:
		var final = Color.BLACK
		for type in flash_colors:
			var flash = lines._flashed.get([key, type], 0.0)
			if flash > 0.0:
				final += color.lerp(flash_colors[type], flash)
		return final if final != Color.BLACK else color
	
	func draw_text(c: CanvasItem, font: Font, text_size: int, flipped: bool, lines: Lines):
		var text = text_fn.call(flipped)
		var size = font.get_multiline_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, text_size)
		c.draw_multiline_string(font,
			Vector2(-size.x - 24, 0) if flipped else Vector2(0, 0),
			text,
			HORIZONTAL_ALIGNMENT_LEFT, -1, text_size, -1, current_color(lines))
	
	func draw_line(c: CanvasItem, begin: Vector2, end: Vector2, color: Color, width: float):
		c.draw_line(begin, end, color, width, true)
	
	func _draw(c: CanvasItem, font: Font, text_size: int, lines: Lines):
		if from == to:
			return
		
		var col := current_color(lines)
		
		c.draw_set_transform(Vector2.ZERO)
		
		var begin = Vector2.ZERO
		var end = Utils.global_rect_of(to).get_center() - from.global_position
		end -= end.normalized() * 12 # keep some distance to the node
		draw_line(c, begin, end, col, lerp(0.02, 1.0, 1.0 / from.get_viewport_transform().get_scale().x))
		
		# arrow head
		var angle = begin.angle_to_point(end)
		var arrow_size = 8
		var arrow = [
			Vector2(0, 0),
			Vector2(-1, -.5),
			Vector2(-1, .5),
		]
		arrow = arrow.map(func (p): return (p * arrow_size).rotated(angle) + end)
		c.draw_polygon(arrow, [col, col, col])
		
		var flip = Utils.between(angle, PI / 2, PI) or Utils.between(angle, -PI, -PI / 2)
		c.draw_set_transform_matrix(Transform2D(angle + PI if flip else angle, Vector2.ZERO) * Transform2D(0.0, Vector2(12, -2)))
		draw_text(c, font, text_size, flip, lines)
		c.draw_set_transform(Vector2.ZERO) # Reset transform for further drawings

class DashedLine extends Line:
	func draw_line(c: CanvasItem, begin: Vector2, end: Vector2, color: Color, width: float):
		c.draw_dashed_line(begin, end, color, width * 2, 2.0)

class CombinedLine extends Line:
	var lines
	
	func current_color(_lines: Lines):
		return color.lerp(Color.RED, Utils.max(lines.map(func (l): return _lines._flashed.get(l.key, 0.0))))
	
	func draw_text(c: CanvasItem, font: Font, text_size: int, flipped: bool, _lines: Lines):
		var y = 0
		for line in lines:
			var text = line.text_fn.call(flipped)
			var color = line.current_color(_lines)
			var size = font.get_multiline_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, text_size)
			c.draw_multiline_string(font,
				Vector2(-size.x - 24, y) if flipped else Vector2(0, y),
				text,
				HORIZONTAL_ALIGNMENT_LEFT, -1, text_size, -1, color)
			y += size.y

class BottomText extends Line:
	func _init(node: Node, label: String):
		super._init(node, node, func (f): return label, label)
		
	func draw_text(c: CanvasItem, font: Font, text_size: int, flipped: bool, lines: Lines):
		var text = text_fn.call(flipped)
		var size = font.get_multiline_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, text_size)
		c.draw_multiline_string(font,
			Vector2(-size.x/2, 0),
			text,
			HORIZONTAL_ALIGNMENT_LEFT, -1, text_size, -1, current_color(lines))
