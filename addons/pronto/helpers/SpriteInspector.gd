extends EditorInspectorPlugin
class_name SpriteInspector

func _can_handle(object):
	return object is PlaceholderBehavior

func _parse_property(object, type, name, hint_type, hint_string, usage_flags, wide):
	if object is PlaceholderBehavior and name == "sprite_library":
		add_property_editor(name, SpriteProperty.new())
		return true
	else:
		return false
	
class SpriteProperty extends EditorProperty:
	var updating = false
	var icon_window
	
	var DEFAULT_TEXTURE = load("res://addons/pronto/icons/MissingTexture.svg")
	var current_value: Texture2D = DEFAULT_TEXTURE
	
	func get_tile_name(x, y):
		if (x in range(24,32) and y in range(0, 11)):
			return "Characters"
		if (x in range(18,24) and y in range(7, 10)):
			return "Characters"
		if (x in range(32,48) and y in range(0, 15)):
			return "Accessories"
		if (x in range(0,488) and y in range(0, 5)):
			return "Nature"
		if (x in range(19,33) and y in range(15, 20)):
			return "Cards"
		return "Unnamed" # Default name.
	
	func _init():
		icon_window = preload("res://addons/pronto/signal_connecting/sprite_window.tscn").instantiate()
		add_child(icon_window)
		icon_window._ready()
		icon_window.texture_selected.connect(_on_change)
		
		var tile_map = icon_window.get_node("TileMap")
		var tile_size = tile_map.cell_quadrant_size
		var tile_source = tile_map.tile_set.get_source(0)
		var tile_texture = tile_source.texture
		var img = tile_source.texture.get_image()
		
		var x_count = tile_texture.get_width() / tile_size
		var y_count = tile_texture.get_height() / tile_size
		
		for x in range(x_count):
			for y in range(y_count):
				var rect = Rect2(tile_size * x, tile_size * y, tile_size, tile_size)
				var image_tex = ImageTexture.create_from_image(img.get_region(rect))
				icon_window.add_icon(image_tex, get_tile_name(x,y))
				
	func _on_change(texture):
		if (updating):
			return
		current_value = texture
		emit_changed(get_edited_property(), current_value)
	
	func _update_property():
		var new_value = get_edited_object()[get_edited_property()]
		if (new_value == current_value):
			return

		# Update the control with the new value.
		updating = true
		current_value = new_value
		updating = false
