@tool
extends TextureRect

signal elapsed()

@export var one_shot: bool:
	get: return _timer.one_shot if _timer else one_shot
	set(value):
		if _timer: _timer.one_shot = value
		else: one_shot
@export var duration_seconds: float:
	get: return _timer.wait_time if _timer else duration_seconds
	set(value):
		if _timer: _timer.wait_time = value
		else: duration_seconds
@export var paused: bool:
	get: return _timer.paused if _timer else paused
	set(value):
		if _timer: _timer.paused = value
		else: paused = value

var _timer: Timer

func _ready():
	texture = preload("res://addons/prototyping/icons/Timer.svg")
	size = Vector2(48, 48)
	
	if not Engine.is_editor_hint():
		_timer = Timer.new()
		_timer.autostart = true
		add_child(_timer)
