@tool
extends Texture2D
class_name EditorIcon

@export var name: String:
	set(n):
		name = n
		_tex = Engine.get_main_loop().get_root().get_theme_icon(name, &"EditorIcons")
		emit_changed()

var _tex: ImageTexture

func _draw(to_canvas_item, pos, modulate, transpose):
	if _tex: _tex.draw(to_canvas_item, pos, modulate, transpose)

func _draw_rect(to_canvas_item: RID, rect: Rect2, tile: bool, modulate: Color, transpose: bool):
	if _tex: _tex.draw_rect(to_canvas_item, rect, tile, modulate, transpose)

func _draw_rect_region(to_canvas_item: RID, rect: Rect2, src_rect: Rect2, modulate: Color, transpose: bool, clip_uv: bool):
	if _tex: _tex.draw_rect_region(to_canvas_item, rect, src_rect, modulate, transpose, clip_uv)

func _get_height():
	if _tex: return _tex.get_height()
	else: return 0

func _get_width():
	if _tex: return _tex.get_width()
	else: return 0

func _has_alpha():
	if _tex: return _tex.has_alpha()
	else: return false

func _is_pixel_opaque(x: int, y: int):
	if _tex: return _tex._is_pixel_opaque(x, y)
	else: return true
