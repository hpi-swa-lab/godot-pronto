@tool
#thumb("Skeleton2D")
extends Behavior
class_name PlaceholderShapeBehavior

@export_enum("Rect", "Circle", "Capsule") var shape_type: String = "Rect":
	set(v):
		shape_type = v
		_re_add_shape()
		queue_redraw()
		_update_shape()
		notify_property_list_changed()

@export var label = "":
	set(v):
		label = v
		queue_redraw()

@export var color = Color.WHITE:
	set(v):
		color = v
		queue_redraw()

var placeholder_size = Vector2(20, 20):
	set(v):
		placeholder_size = v
		queue_redraw()
		_update_shape()

## If true, this placeholder's parent will be moved instead of the placeholder in the editor.
## Convenient for not having to switch selected items all the time.
@export var keep_in_origin = true

var capsule_height: float = 30:
	set(v):
		if v < capsule_radius*2:
			capsule_radius = v/2
		capsule_height = v
		queue_redraw()
		_update_shape()
		
var capsule_radius: float = 10:
	set(v):
		capsule_radius = v
		queue_redraw()
		_update_shape()

var circle_radius: float = 10:
	set(v):
		circle_radius = v
		queue_redraw()
		_update_shape()

var size: Vector2:
	get:
		return placeholder_size
		
var undefined_shape_string = "Please set a shape for Placeholder:" + str(name) + ". We will pretend it is a Rect for backwards compatability."

# todo: figure out why this doesn't work with new forms
func should_keep_in_origin():
	return keep_in_origin and get_parent() is CollisionObject2D

func _update_shape():
	if _parent:
		_parent.shape_owner_set_transform(_owner_id, transform)
		if shape_type == "Rect":
			_parent.shape_owner_get_shape(_owner_id, 0).size = placeholder_size
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
	if shape_type == "Rect":
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
	elif shape_type == "Circle":
		# feel free to improve text size calculation
		var text_size = min(circle_radius*1.5, circle_radius*2.1 / label.length() * 1.8)
		draw_circle(Vector2(0,0),circle_radius,color)
		draw_string(default_font, Vector2(-circle_radius,+text_size/4),label,HORIZONTAL_ALIGNMENT_CENTER,-1,text_size,Color.WHITE if color.get_luminance() < 0.6 else Color.BLACK)
		if get_tree().debug_collisions_hint:
			_draw_debug_circle()
		
	elif shape_type == "Capsule":
		# feel free to improve text size calculation
		var text_size = min(capsule_radius, capsule_radius*2 / label.length() * 1.8)
		draw_circle(Vector2(0,-(capsule_height/2)+capsule_radius),capsule_radius, color)
		draw_circle(Vector2(0,+(capsule_height/2)-capsule_radius),capsule_radius, color)
		draw_rect(Rect2(-(capsule_radius),-(capsule_height/2)+capsule_radius,2*capsule_radius,capsule_height-(capsule_radius*2)), color, true)
		draw_string(default_font, Vector2(-capsule_radius,+text_size/4),label,HORIZONTAL_ALIGNMENT_CENTER,-1,text_size,Color.WHITE if color.get_luminance() < 0.6 else Color.BLACK)
		if get_tree().debug_collisions_hint:
			_draw_debug_capsule()
	else:
		# no shape has been set, should only exist for legacy scenes
		print(undefined_shape_string)
		var height = placeholder_size.y
		var text_size = min(height, placeholder_size.x / label.length() * 1.8)
		draw_rect(Rect2(placeholder_size / -2, placeholder_size), color, true)
		draw_string(default_font,
			placeholder_size / -2 + Vector2(0, height / 2 + text_size / 4),
			"PLEASE SELECT A SHAPE FOR ME",
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
	
func _re_add_shape():
	_parent = get_parent() as CollisionObject2D
	if _parent:
		if _owner_id != 0:
			_parent.remove_shape_owner(_owner_id)
		if shape_type == "Rect":
			var shape = RectangleShape2D.new()
			shape.size = placeholder_size
			_owner_id = _parent.create_shape_owner(self)
			_parent.shape_owner_add_shape(_owner_id, shape)
		elif shape_type == "Circle":
			var shape = CircleShape2D.new()
			shape.radius = circle_radius
			_owner_id = _parent.create_shape_owner(self)
			_parent.shape_owner_add_shape(_owner_id, shape)
		elif shape_type == "Capsule":
			var shape = CapsuleShape2D.new()
			shape.radius = capsule_radius
			shape.height = capsule_height
			_owner_id = _parent.create_shape_owner(self)
			_parent.shape_owner_add_shape(_owner_id, shape)
		else:
			# no shape has been set, should only exist for legacy scenes
			print(undefined_shape_string)
			var shape = RectangleShape2D.new()
			shape.size = placeholder_size
			_owner_id = _parent.create_shape_owner(self)
			_parent.shape_owner_add_shape(_owner_id, shape)

# position: Vector2, 
# icon: Texture,
# object: Object, 
# property: String, 
# map: Callable, 
# local_space = true

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
