@tool
#thumb("Skeleton2D")
extends Behavior
class_name PlaceholderBehavior

const OUTLINE_SHADER = "res://addons/pronto/shader/outline.gdshader"

## The label that is shown inside the Placeholder, unless a sprite is used.
@export var label = "":
	set(v):
		label = v
		queue_redraw()

## The color used for the placeholder.
@export var color = Color.WHITE:
	set(v):
		color = v
		if sprite and sprite.material:
			sprite.self_modulate = v
			sprite.material.set_shader_parameter("tint_color", v)
		queue_redraw()
		
## If [code]true[/code], this Placeholder's parent will be moved instead of the placeholder in the editor.
## Convenient for not having to switch selected items all the time.
@export var keep_in_origin = true

var undefined_shape_string = "Please set a shape for Placeholder:" + str(name) + ". We will pretend it is a Rect for backwards compatability."

## Placeholder options for displaying a [class Sprite2D] instead of a shape.
@export_category("Sprite")

## If [code]true[/code] a [class Sprite2D] is shown.
@export var use_sprite = false:
	set(v):
		use_sprite = v
		_editor_reload()
		queue_redraw()

# The default texture used for the [class Sprite2D].
var DEFAULT_TEXTURE = load("res://addons/pronto/icons/MissingTexture.svg")

## The texture used for the [class Sprite2D]. Can be loaded from a file or from the sprite_library.
@export var sprite_texture: Texture2D = DEFAULT_TEXTURE:
	set(v):
		if v == null:
			sprite_texture = DEFAULT_TEXTURE
		else:
			sprite_texture = v
		_editor_reload()

## The sprite library is desribed in [class SpriteInspector] as well as
## "addons/pronto/helpers/sprite_window.tscn".
## Search through a library of textures to choose your sprite.
@export var sprite_library: Texture2D:
	set(v):
		if v == null: return
		sprite_texture = v
		use_sprite = true

## Settings for configuring the outline.
@export_category("Outline")

## If [code]true[/code], the outline is shown.
@export var outline_visible: bool = false:
	set(v):
		outline_visible = v
		_editor_reload()

## The color used for the outline.
@export var outline_color: Color = Color.YELLOW:
	set(v):
		outline_color = v
		_editor_reload()

## The width of the outline.
@export var outline_width: float = 1:
	set(v):
		outline_width = v;
		_editor_reload()

## The rounding method for corners of the outline (only used if [class Sprite2D] is used).
@export_enum("Circle", "Diamond", "Square") var outline_pattern = 0:
	set(v):
		outline_pattern = v
		_editor_reload()
		
## Settings for Shape (Collision and Display)
@export_category("Shape")

## This will define the shape of the placeholder as well as the shape of the hitbox.
@export_enum("Rect", "Circle", "Capsule") var shape_type: String = "Rect":
	set(v):
		shape_type = v
		_re_add_shape()
		queue_redraw()
		_editor_reload()
		_update_shape()
		notify_property_list_changed()

## The size of the placeholder.
var placeholder_size = Vector2(20, 20):
	set(v):
		placeholder_size = v
		_re_add_shape()
		_editor_reload()
		_update_shape()

## The height of the capsule.
var capsule_height: float = 30:
	set(v):
		if v < capsule_radius*2:
			capsule_radius = v/2
		capsule_height = v
		_re_add_shape()
		_editor_reload()
		_update_shape()
	
## The radius of the capsule.	
var capsule_radius: float = 10:
	set(v):
		if v < capsule_height/2:
			capsule_radius = v
			_re_add_shape()
			_editor_reload()
			_update_shape()

## The radius of the circle.
var circle_radius: float = 10:
	set(v):
		circle_radius = v
		_re_add_shape()
		_editor_reload()
		_update_shape()
		

# The [class Sprite2D] used as a child in the Placeholder.
var sprite: Sprite2D

# The size of the Placeholder, overridden by the [member PlaceholderBehavior.placeholder_size].
var size: Vector2:
	get:
		return placeholder_size
		
func _ready():
	super._ready()
	for child in get_children(true):
		if child is Sprite2D:
			child.queue_free()
	if use_sprite:
		_init_sprite()
		if sprite.get_parent() != self:
			add_child(sprite, false, INTERNAL_MODE_FRONT)
		sprite.position = sprite.position - find_non_transparent_rect().get_center()
	_update_shape()

func _editor_reload():
	if Engine.is_editor_hint() and is_active_scene():
		for child in get_children(true):
			if child is Sprite2D and child != sprite:
				child.queue_free()
		_ready()
	queue_redraw()
	
func _shape_boundary():
	if shape:
		return (shape as Shape2D).get_rect().size
	else:
		return placeholder_size

func _init_sprite():
	sprite = Sprite2D.new()
	sprite.texture = sprite_texture
	var shader_mat = ShaderMaterial.new()
	shader_mat.shader = load(OUTLINE_SHADER)
	# to hide the shader we set its width to 0 if outline_visible is false
	shader_mat.set_shader_parameter("width", outline_width if outline_visible else 0)
	shader_mat.set_shader_parameter("color", outline_color)
	shader_mat.set_shader_parameter("tint_color", color)
	shader_mat.set_shader_parameter("pattern", outline_pattern)
	sprite.material = shader_mat
	sprite.scale = _shape_boundary() / sprite.texture.get_size()
	
## Shows an outline around the Placeholder.
func show_outline():
	outline_visible = true
	if use_sprite:
		var material = sprite.material as ShaderMaterial
		material.set_shader_parameter("width", outline_width)
	queue_redraw()

## Hides the outline around the Placeholder.
func hide_outline():
	outline_visible = false
	if use_sprite:
		(sprite.material as ShaderMaterial).set_shader_parameter("width", 0)
	queue_redraw()
	
## Toggles the visibility of the outline according to the given parameter.
func set_outline_visible(visible):
	if visible:
		hide_outline()
	else:
		show_outline()


## Tween used for flashing
var _flash_tween : Tween

## Color to restore when restarting flash
var _restore_color : Color

var shape

## Flashes this Placeholder a certain color for a duration.
## It will take on the desired color immediately and return to its original
## color over the given duration.
func flash(color: Color, duration: float = 0.3):
	if _flash_tween:
		if _flash_tween.is_running():
			self.color = _restore_color
		_flash_tween.kill()
	
	_restore_color = self.color
	_flash_tween = create_tween()
	_flash_tween.tween_property(self, "color", self.color, duration)
	_flash_tween.set_ease(Tween.EASE_OUT)
	self.color = color

func should_keep_in_origin():
	return keep_in_origin and get_parent() is CollisionObject2D

func _update_shape():
	if _parent:
		_parent.shape_owner_set_transform(_owner_id, transform)
		if shape_type == "Rect":
			_parent.shape_owner_get_shape(_owner_id, 0).size = placeholder_size
			if use_sprite and sprite:
				_parent.shape_owner_get_shape(_owner_id, 0).size = find_non_transparent_rect().size
				print("update shape")
		elif shape_type == "Circle":
			_parent.shape_owner_get_shape(_owner_id, 0).radius = circle_radius
		elif shape_type == "Capsule":
			_parent.shape_owner_get_shape(_owner_id, 0).radius = capsule_radius
			_parent.shape_owner_get_shape(_owner_id, 0).height = capsule_height
		else:
			# no shape has been set, should only exist for legacy scenes
			print(undefined_shape_string)	
			_parent.shape_owner_get_shape(_owner_id, 0).size = placeholder_size

var _owner_id: int = 0
var _parent: CollisionObject2D = null
func _notification(what):
	match what:
		NOTIFICATION_PARENTED:
			_re_add_shape()
			_update_shape()
		NOTIFICATION_ENTER_TREE, NOTIFICATION_LOCAL_TRANSFORM_CHANGED:
			_update_shape()
		NOTIFICATION_UNPARENTED:
			if _parent:
				_parent.remove_shape_owner(_owner_id)
				_parent = null
				_owner_id = 0

func show_icon():
	return false

func _get_property_list():
	var properties = []
	if shape_type == "Rect":
		properties.append({
			"name": "placeholder_size",
			"type": TYPE_VECTOR2,
		})
	elif shape_type == "Circle":
		properties.append({
			"name": "circle_radius",
			"type": TYPE_FLOAT,
		})

	elif shape_type == "Capsule":
		properties.append({
			"name": "capsule_height",
			"type": TYPE_FLOAT,
		})
		properties.append({
			"name": "capsule_radius",
			"type": TYPE_FLOAT,
		})
	else:
		# no shape has been set, should only exist for legacy scenes
		properties.append({
			"name": "placeholder_size",
			"type": TYPE_VECTOR2,
		})
	return properties

func _draw():
	super._draw()
	
	var default_font = ThemeDB.fallback_font
	var height = placeholder_size.y
	var text_size = min(height, placeholder_size.x / label.length() * 1.8)
	var text_color = Color(Color.WHITE if color.get_luminance() < 0.6 else Color.BLACK, color.a)
	
	if not use_sprite:
		if shape_type == "Rect":
			draw_rect(Rect2(placeholder_size / -2, placeholder_size), color, true)
			draw_string(default_font,
				placeholder_size / -2 + Vector2(0, height / 2 + text_size / 4),
				label,
				HORIZONTAL_ALIGNMENT_CENTER,
				-1,
				text_size,
				text_color)
			if outline_visible:
				draw_rect(Rect2(placeholder_size / -2, placeholder_size), outline_color, false, outline_width)
		elif shape_type == "Circle":
			# feel free to improve text size calculation
			text_size = min(circle_radius*1.5, circle_radius*2.1 / label.length() * 1.8)
			draw_circle(Vector2(0,0),circle_radius,color)
			draw_string(default_font, Vector2(-circle_radius,+text_size/4),label,HORIZONTAL_ALIGNMENT_CENTER,-1,text_size,text_color)
			if outline_visible:
				draw_arc(Vector2(0,0), circle_radius, 0, 360, 1000, outline_color, outline_width)
		elif shape_type == "Capsule":
			# feel free to improve text size calculation
			text_size = min(capsule_radius, capsule_radius*2 / label.length() * 1.8)
			draw_circle(Vector2(0,-(capsule_height/2)+capsule_radius),capsule_radius, color)
			draw_circle(Vector2(0,+(capsule_height/2)-capsule_radius),capsule_radius, color)
			draw_rect(Rect2(-(capsule_radius),-(capsule_height/2)+capsule_radius,2*capsule_radius,capsule_height-(capsule_radius*2)), color, true)
			draw_string(default_font, Vector2(-capsule_radius,+text_size/4),label,HORIZONTAL_ALIGNMENT_CENTER,-1,text_size,text_color)
			if outline_visible:
				draw_arc(Vector2(0,-(capsule_height/2)+capsule_radius), capsule_radius, TAU/2, TAU, 500, outline_color, outline_width)
				var rect  = Rect2(-(capsule_radius),-(capsule_height/2)+capsule_radius,2*capsule_radius,capsule_height-(capsule_radius*2))
				draw_line(rect.position, rect.position + Vector2(0, rect.size.y), outline_color, outline_width)
				draw_line(rect.position + Vector2(rect.size.x, 0), rect.position + rect.size, outline_color, outline_width)
				draw_arc(Vector2(0,+(capsule_height/2)-capsule_radius), capsule_radius, 0, TAU/2, 500, outline_color, outline_width)
		else:
			# no shape has been set, should only exist for legacy scenes
			print(undefined_shape_string)
			height = placeholder_size.y
			text_size = min(height, placeholder_size.x / label.length() * 1.8)
			draw_rect(Rect2(placeholder_size / -2, placeholder_size), color, true)
			draw_string(default_font,
				placeholder_size / -2 + Vector2(0, height / 2 + text_size / 4),
				"PLEASE SELECT A SHAPE FOR ME",
				HORIZONTAL_ALIGNMENT_CENTER,
				-1,
				text_size,
				Color.WHITE if color.get_luminance() < 0.6 else Color.BLACK)
			if outline_visible:
				draw_rect(Rect2(placeholder_size / -2, placeholder_size), outline_color, false, outline_width)

	if get_tree().debug_collisions_hint:
		if shape_type == "Rect":
			var debug_color = Color.LIGHT_BLUE
			debug_color.a = 0.5
			var r = Rect2(placeholder_size / -2, placeholder_size)
			if use_sprite:
				r = find_non_transparent_rect()
				r.position = r.position - r.get_center()
			draw_rect(r, debug_color, true)
			debug_color.a = 1
			draw_rect(r, debug_color, false)
		elif shape_type == "Circle":
			_draw_debug_circle()
			
		elif shape_type == "Capsule":
			_draw_debug_capsule()
		else:
			var debug_color = Color.LIGHT_BLUE
			debug_color.a = 0.5
			var r = Rect2(placeholder_size / -2, placeholder_size)
			draw_rect(r, debug_color, true)
			debug_color.a = 1
			draw_rect(r, debug_color, false)

func find_non_transparent_rect():
	if not sprite_texture: return null
	var w = sprite_texture.get_width()
	var h = sprite_texture.get_height()
	var minX = w
	var minY = h
	var maxX = 0
	var maxY = 0
	for y in range(h):
		for x in range(w):
			var pixel = sprite_texture.get_image().get_pixel(x,y)
			if pixel.a > 0:
				minX = min(minX, x)
				minY = min(minY, y)
				maxX = max(maxX, x)
				maxY = max(maxY, y)

	var scale = placeholder_size / 16
	var size = Vector2(maxX - minX + 1, maxY - minY + 1) * scale
	return Rect2(-Vector2(w/2-minX,h/2-minY) * scale, size)

func _re_add_shape():
	_parent = get_parent() as CollisionObject2D
	if _parent:
		if _owner_id != 0:
			_parent.remove_shape_owner(_owner_id)
		if shape_type == "Rect":
			shape = RectangleShape2D.new()
			shape.size = placeholder_size
			_owner_id = _parent.create_shape_owner(self)
			_parent.shape_owner_add_shape(_owner_id, shape)
		elif shape_type == "Circle":
			shape = CircleShape2D.new()
			shape.radius = circle_radius
			_owner_id = _parent.create_shape_owner(self)
			_parent.shape_owner_add_shape(_owner_id, shape)
		elif shape_type == "Capsule":
			shape = CapsuleShape2D.new()
			shape.radius = capsule_radius
			shape.height = capsule_height
			_owner_id = _parent.create_shape_owner(self)
			_parent.shape_owner_add_shape(_owner_id, shape)
		else:
			# no shape has been set, should only exist for legacy scenes
			print(undefined_shape_string)
			shape = RectangleShape2D.new()
			shape.size = placeholder_size
			_owner_id = _parent.create_shape_owner(self)
			_parent.shape_owner_add_shape(_owner_id, shape)
	else:
		if shape_type == "Rect":
			shape = RectangleShape2D.new()
			shape.size = placeholder_size
		elif shape_type == "Circle":
			shape = CircleShape2D.new()
			shape.radius = circle_radius
		elif shape_type == "Capsule":
			shape = CapsuleShape2D.new()
			shape.radius = capsule_radius
			shape.height = capsule_height
		else:
			# no shape has been set, should only exist for legacy scenes
			print(undefined_shape_string)
			shape = RectangleShape2D.new()
			shape.size = placeholder_size
			
func _draw_debug_circle():
	var debug_color = Color.LIGHT_BLUE
	debug_color.a = 0.5
	draw_circle(Vector2(0,0),circle_radius,debug_color)
	debug_color.a = 1
	draw_circle(Vector2(0,0),circle_radius,debug_color)
	
func _draw_debug_capsule():
	var debug_color = Color.LIGHT_BLUE
	debug_color.a = 0.5
	draw_circle(Vector2(0,-(capsule_height/2)+capsule_radius),capsule_radius, debug_color)
	draw_circle(Vector2(0,+(capsule_height/2)-capsule_radius),capsule_radius, debug_color)
	draw_rect(Rect2(-(capsule_radius),-(capsule_height/2)+capsule_radius,2*capsule_radius,capsule_height-(capsule_radius*2)), debug_color, true)
	debug_color.a = 1
	draw_circle(Vector2(0,-(capsule_height/2)+capsule_radius),capsule_radius, debug_color)
	draw_circle(Vector2(0,+(capsule_height/2)-capsule_radius),capsule_radius, debug_color)
	draw_rect(Rect2(-(capsule_radius),-(capsule_height/2)+capsule_radius,2*capsule_radius,capsule_height-(capsule_radius*2)), debug_color, true)

func handles():
	if shape_type == "Rect":
		return [
			Handles.SetPropHandle.new(
				(transform * placeholder_size - position) / 2,
				Utils.icon_from_theme("EditorHandle", self),
				self,
				"placeholder_size",
				func (coord): return (floor(coord * 2) * transform.translated(-position)).clamp(Vector2(1, 1), Vector2(10000, 10000)))
		]
	elif shape_type == "Circle":
		return [
			Handles.SetPropHandle.new(
				(transform * Vector2(circle_radius, 0) - position),
				Utils.icon_from_theme("EditorHandle", self),
				self,
				"circle_radius",
				func (coord): return clamp(coord.distance_to(Vector2(0,0)),1.0, 10000.0))
		]
	elif shape_type == "Capsule":
		return [
			Handles.SetPropHandle.new(
				(transform * Vector2(capsule_radius, 0) - position),
				Utils.icon_from_theme("EditorHandle", self),
				self,
				"capsule_radius",
				func (coord): return clamp(coord.distance_to(Vector2(0,0)),1.0, 10000.0)),
			Handles.SetPropHandle.new(
				(transform * Vector2(0, capsule_height/2) - position),
				Utils.icon_from_theme("EditorHandle", self),
				self,
				"capsule_height",
				func (coord): return clamp(coord.distance_to(Vector2(0,0)),1.0, 10000.0)*2)
		]
	else:
		# no shape has been set, should only exist for legacy scenes
		print(undefined_shape_string)
		return [
			Handles.SetPropHandle.new(
				(transform * placeholder_size - position) / 2,
				Utils.icon_from_theme("EditorHandle", self),
				self,
				"placeholder_size",
				func (coord): return (floor(coord * 2) * transform.translated(-position)).clamp(Vector2(1, 1), Vector2(10000, 10000)))
		]

func _groupDrawerRadius():
	return placeholder_size.length() / 2 + 20
