extends Resource
class_name ValueResource

@export var selectType: String = "Float"

@export var float_from: float = 0
@export var float_value: float = 0
@export var float_to: float = 0
@export var float_step_size: float = 0.1

@export var bool_value: String = "False"

@export var enum_value: String = ""

func _set_from_value(obj: ValueBehavior):
	selectType = obj.selectType
	match obj.selectType:
		"Float":
			float_step_size = obj.float_step_size
			float_from = obj.float_from
			float_to = obj.float_to
			float_value = obj.float_value
		"Enum":
			enum_value = obj.enum_value
		"Bool":
			bool_value = obj.bool_value
