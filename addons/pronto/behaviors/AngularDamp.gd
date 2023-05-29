@tool
#thumb("InterpLinearAngle")
extends Behavior

@onready var _parent: Area2D = get_parent()

@export var space_override: Area2D.SpaceOverride:
	get: return _parent.angular_damp_space_override
	set(value): 
		_parent.angular_damp_space_override = value
		notify_property_list_changed()

var strength: float:
	get: return _parent.angular_damp
	set(value):
		_parent.angular_damp = value

func _enter_tree():
	if not get_parent() is Area2D:
		push_error("LinearDamp must be a child of an Area2D")

func _get_property_list():
	return [{
		"name": "strength",
		"type": TYPE_FLOAT,
		"usage": PROPERTY_USAGE_NO_EDITOR if space_override == Area2D.SPACE_OVERRIDE_DISABLED else PROPERTY_USAGE_DEFAULT,
		"hint_string": "Strength of the angular dampening."
	}]

func _ready():
	pass

func _process(delta):
	pass
