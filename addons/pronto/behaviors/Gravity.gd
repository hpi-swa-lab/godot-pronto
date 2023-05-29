@tool
#thumb("ControlAlignCenter")
extends Behavior

@onready var _parent: Area2D = get_parent()

@export var space_override: Area2D.SpaceOverride:
	get: return _parent.gravity_space_override
	set(value): 
		_parent.gravity_space_override = value
		notify_property_list_changed()

var is_point: bool:
	get: return _parent.gravity_point
	set(value):
		_parent.gravity_point = value
		notify_property_list_changed()

var direction: Vector2:
	get: return _parent.gravity_direction
	set(value):
		_parent.gravity_direction = value

var strength: float:
	get: return _parent.gravity
	set(value):
		_parent.gravity = value

var point_center: Vector2:
	get: return _parent.gravity_point_center
	set(value):
		_parent.gravity_point_center = value
	
var point_unit_distance: float:
	get: return _parent.gravity_point_unit_distance
	set(value):
		_parent.gravity_point_unit_distance = value

func _enter_tree():
	if not get_parent() is Area2D:
		push_error("Gravity must be a child of an Area2D")

func _get_property_list():
	var properties = []
	
	var property_usage_general = PROPERTY_USAGE_NO_EDITOR
	if space_override != Area2D.SpaceOverride.SPACE_OVERRIDE_DISABLED:
		property_usage_general = PROPERTY_USAGE_DEFAULT
	
	var property_usage_point_gravity = PROPERTY_USAGE_NO_EDITOR
	if space_override != Area2D.SpaceOverride.SPACE_OVERRIDE_DISABLED and is_point:
		property_usage_point_gravity = PROPERTY_USAGE_DEFAULT
	
	var property_usage_homogeneous_gravity
	if space_override != Area2D.SpaceOverride.SPACE_OVERRIDE_DISABLED and not is_point:
		property_usage_homogeneous_gravity = PROPERTY_USAGE_DEFAULT
	
	properties.append({
		"name": "is_point",
		"type": TYPE_BOOL,
		"usage": property_usage_general,
		"hint_string": "Choose whether the gravity should be a point gravity (`true`) or a homogeneous one (`false`)."
	})
	
	properties.append({
		"name": "strength",
		"type": TYPE_FLOAT,
		"usage": property_usage_general,
		"hint_string": "Strength of the gravitational pull. Default is 980 to emulate earth's gravity."
	})
	
	properties.append({
		"name": "direction",
		"type": TYPE_VECTOR2,
		"usage": property_usage_homogeneous_gravity,
		"hint_string": "Direction of the gravitational pull"
	})
	
	properties.append({
		"name": "point_center",
		"type": TYPE_VECTOR2,
		"usage": property_usage_point_gravity,
		"hint_string": "Center point of the gravity"
	})
	
	properties.append({
		"name": "point_unit_distance",
		"type": TYPE_FLOAT,
		"usage": property_usage_point_gravity,
		"hint_string": "The distance at which the gravity strength is equal to `strength`"
	})
	
	return properties

func _ready():
	pass

func _process(delta):
	pass
