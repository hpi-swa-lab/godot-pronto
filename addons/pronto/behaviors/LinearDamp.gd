@tool
#thumb("Line")
extends Behavior

@onready var _parent: Area2D = get_parent()

var _prior_space_override: Area2D.SpaceOverride

@export var space_override: Area2D.SpaceOverride:
	get: return _parent.linear_damp_space_override
	set(value): 
		if (value != space_override):
			_prior_space_override = space_override
		
		_parent.linear_damp_space_override = value
		notify_property_list_changed()

var strength: float:
	get: return _parent.linear_damp
	set(value):
		_parent.linear_damp = value

var paused: bool:
	get: return _parent.linear_damp_space_override == Area2D.SPACE_OVERRIDE_DISABLED
	set(value):
		if value:
			space_override = Area2D.SPACE_OVERRIDE_DISABLED
		else:
			space_override = _prior_space_override

func _enter_tree():
	if not get_parent() is Area2D:
		push_error("LinearDamp must be a child of an Area2D")

func _get_property_list():
	return [{
		"name": "strength",
		"type": TYPE_FLOAT,
		"usage": PROPERTY_USAGE_NO_EDITOR if space_override == Area2D.SPACE_OVERRIDE_DISABLED else PROPERTY_USAGE_DEFAULT,
		"hint_string": "Strength of the linear dampening."
	}]

func _ready():
	pass

func _process(delta):
	pass
