@tool
extends Sprite2D
class_name BehaviorIcon

var _data = ""
@export_file("*.svg") var path: String = "":
	get: return path
	set(value):
		path = value
		var file = FileAccess.open(path, FileAccess.READ)
		_data = file.get_as_text()
		_update_texture()

func _ready():
	centered = true

var _current_zoom = 1
func _process(_dt):
	var zoom = get_viewport_transform().get_scale().x
	if _current_zoom != zoom:
		_current_zoom = zoom
		_update_texture()

func _update_texture():
	if _data.length() == 0: return
	
	var image = Image.new()
	image.load_svg_from_string(_data, _current_zoom)
	image.fix_alpha_edges()
	
	var texture = ImageTexture.new()
	texture.set_image(image)
	
	self.texture = texture
	self.scale = Vector2(1.0 / _current_zoom, 1.0 / _current_zoom)
