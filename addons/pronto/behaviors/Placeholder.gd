@tool
#thumb("Skeleton2D")
extends Behavior

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

func _ready():
	super._ready()

func _update_shape():
	_parent.shape_owner_set_transform(_owner_id, transform)
	_parent.shape_owner_get_shape(_owner_id, 0).size = placeholder_size

var _owner_id: int = 0
var _parent: CollisionObject2D = null
func _notification(what):
	match what:
		NOTIFICATION_PARENTED:
			var shape = RectangleShape2D.new()
			shape.size = placeholder_size
			_parent = get_parent() as CollisionObject2D
			_owner_id = _parent.create_shape_owner(self)
			_parent.shape_owner_add_shape(_owner_id, shape)
			_update_shape()
		NOTIFICATION_ENTER_TREE, NOTIFICATION_LOCAL_TRANSFORM_CHANGED:
			if _parent: _update_shape()
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

func handles():
	return [
		Handles.SetPropHandle.new(placeholder_size / 2,
			Utils.icon_from_theme("EditorHandle", self),
			self,
			"placeholder_size",
			func (coord): return floor(coord * 2).clamp(Vector2(1, 1), Vector2(10000, 10000)))
	]
