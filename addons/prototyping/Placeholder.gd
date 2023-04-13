@tool
extends TextureRect

@export var label = "":
	set(v):
		label = v
		queue_redraw()
@export var color = Color.WHITE:
	set(v):
		color = v
		queue_redraw()

# func _ready():
#	queue_redraw()

func _draw():
	var default_font = ThemeDB.fallback_font
	var height = get_rect().size.y
	var size = min(height, get_rect().size.x / label.length() * 1.8)
	draw_rect(Rect2(Vector2.ZERO, get_rect().size), color, true)
	draw_string(default_font, Vector2.ZERO + Vector2(0, height / 2 + size / 4), label, HORIZONTAL_ALIGNMENT_CENTER, -1, size, Color.WHITE if color.get_luminance() < 0.6 else Color.BLACK)
