@tool
#thumb("Skeleton2D")
extends Behavior
class_name Placeholder

const OUTLINE_SHADER = "res://addons/pronto/shader/outline.gdshader"

## The label that is shown inside the Placholder, unless a sprite is used.
@export var label = "":
	set(v):
		label = v
		queue_redraw()

## The color used for the placeholder.
@export var color = Color.WHITE:
	set(v):
		color = v
		queue_redraw()

## The size of the placeholder.
@export var placeholder_size = Vector2(20, 20):
	set(v):
		placeholder_size = v
		_editor_reload()
		_update_shape()
		
## If [code]true[/code], this Placeholder's parent will be moved instead of the placeholder in the editor.
## Convenient for not having to switch selected items all the time.
@export var keep_in_origin = true

## Placeholder options for displaying a Sprite2D instead of a shape.
@export_category("Sprite")

## If [code]true[/code] a Sprite2D is shown.
@export var use_sprite = false:
	set(v):
		use_sprite = v
		_editor_reload()
		queue_redraw()

# The default texture used for the Sprite2D.
var DEFAULT_TEXTURE = load("res://addons/pronto/icons/MissingTexture.svg")

## The texture used for the Sprite2D.
@export var sprite_texture: Texture2D = DEFAULT_TEXTURE:
	set(v):
		if v == null:
			sprite_texture = DEFAULT_TEXTURE
		else:
			sprite_texture = v
		_editor_reload()

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

## The rounding method for corners of the outline (only used if sprite is used).
@export_enum("Circle", "Diamond", "Square") var outline_pattern = 0:
	set(v):
		outline_pattern = v
		_editor_reload()

# The Sprite2D used as a child in the Placeholder.
var sprite: Sprite2D = Sprite2D.new()

# The size of the Placholder, overridden by the placeholder_size.
var size: Vector2:
	get:
		return placeholder_size
		
func _ready():
	super._ready()
	if use_sprite:
		_init_sprite()
		self.add_child(sprite, false, INTERNAL_MODE_FRONT)
		
func _editor_reload():
	if Engine.is_editor_hint() and is_active_scene():
		if sprite.get_parent():
			remove_child(sprite)
		_ready()
	queue_redraw()

func _init_sprite():
	sprite.texture = sprite_texture
	
	var shader_mat = ShaderMaterial.new()
	shader_mat.shader = load(OUTLINE_SHADER)
	# to hide the shader we set its width to 0 if outline_visible is false
	shader_mat.set_shader_parameter("width", outline_width if outline_visible else 0)
	shader_mat.set_shader_parameter("color", outline_color)
	shader_mat.set_shader_parameter("pattern", outline_pattern)
	sprite.material = shader_mat
	sprite.scale = placeholder_size / sprite.texture.get_size()
	
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

## Flashes this Placeholder a certain color for a duration.
## It will take on the desired color immediately and return to its original
## color over the given duration.
func flash(color: Color, duration: float = 0.2):
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
		_parent.shape_owner_get_shape(_owner_id, 0).size = placeholder_size

var _owner_id: int = 0
var _parent: CollisionObject2D = null
func _notification(what):
	match what:
		NOTIFICATION_PARENTED:
			_parent = get_parent() as CollisionObject2D
			if _parent:
				var shape = RectangleShape2D.new()
				shape.size = placeholder_size
				_owner_id = _parent.create_shape_owner(self)
				_parent.shape_owner_add_shape(_owner_id, shape)
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

func _draw():
	super._draw()
	
	var default_font = ThemeDB.fallback_font
	var height = placeholder_size.y
	var text_size = min(height, placeholder_size.x / label.length() * 1.8)
	
	if not use_sprite:
		draw_rect(Rect2(placeholder_size / -2, placeholder_size), color, true)
		draw_string(default_font,
			placeholder_size / -2 + Vector2(0, height / 2 + text_size / 4),
			label,
			HORIZONTAL_ALIGNMENT_CENTER,
			-1,
			text_size,
			Color.WHITE if color.get_luminance() < 0.6 else Color.BLACK)
		
		if outline_visible:
			draw_rect(Rect2(placeholder_size / -2, placeholder_size), outline_color, false, outline_width)

	if get_tree().debug_collisions_hint:
		var debug_color = Color.LIGHT_BLUE
		debug_color.a = 0.5
		var r = Rect2(placeholder_size / -2, placeholder_size)
		draw_rect(r, debug_color, true)
		debug_color.a = 1
		draw_rect(r, debug_color, false)

func handles():
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
