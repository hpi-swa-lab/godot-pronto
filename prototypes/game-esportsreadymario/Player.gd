extends CharacterBody2D

var _start_position = Vector2(0,0)

func _ready():
	_start_position = position


func reset():
	position = _start_position
	get_node("HealthBarBehavior").current = get_node("HealthBarBehavior").max/2
