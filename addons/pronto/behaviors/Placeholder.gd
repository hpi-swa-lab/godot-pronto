@tool
#thumb("Skeleton2D")
extends Behavior
class_name Placeholder

@export var label = "":
	set(v):
		label = v
		queue_redraw()

@export var color = Color.WHITE:
	set(v):
		color = v
		queue_redraw()

@export var placeholder_size = Vector2(20, 20):
	set(v):
		placeholder_size = v
		queue_redraw()
		_update_shape()

## If true, this placeholder's parent will be moved instead of the placeholder in the editor.
## Convenient for not having to switch selected items all the time.
@export var keep_in_origin = true

var size: Vector2:
	get:
		return placeholder_size

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
	draw_rect(Rect2(placeholder_size / -2, placeholder_size), color, true)
	draw_string(default_font,
		placeholder_size / -2 + Vector2(0, height / 2 + text_size / 4),
		label,
		HORIZONTAL_ALIGNMENT_CENTER,
		-1,
		text_size,
		Color.WHITE if color.get_luminance() < 0.6 else Color.BLACK)
	
	if get_tree().debug_collisions_hint:
		var debug_color = Color.LIGHT_BLUE
		debug_color.a = 0.5
		var r = Rect2(placeholder_size / -2, placeholder_size)
		draw_rect(r, debug_color, true)
		debug_color.a = 1
		draw_rect(r, debug_color, false)

# position: Vector2, 
# icon: Texture,
# object: Object, 
# property: String, 
# map: Callable, 
# local_space = true

func handles():
	return [
		Handles.SetPropHandle.new(
			(global_transform * placeholder_size - global_position) / 2,
			Utils.icon_from_theme("EditorHandle", self),
			self,
			"placeholder_size",
			func (coord): return floor((coord * 2 + global_position) * global_transform).clamp(Vector2(1, 1), Vector2(10000, 10000)))
	]
