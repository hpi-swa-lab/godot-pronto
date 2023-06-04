extends CharacterBody2D

@onready var _follow: PathFollow2D = get_parent()
@export var speed: float = 60.0
@export var paused: bool = true
var is_finished: bool = false

func _physics_process(delta):
	if (paused):
		return
	if is_finished:
		get_node("Placeholder").color = Color.DARK_GREEN
		return
	_follow.set_progress(_follow.get_progress() + speed * delta)
	if not _follow.loop && _follow.get_progress_ratio() >= 1:
		is_finished = true
		for follow in _follow.get_parent().get_children():
			follow.get_node("SnakeBlock").is_finished = true
			follow.get_node("Clock").reset_and_start()
			
func activate_snake():
	if not paused:
		return
	for follow in _follow.get_parent().get_children():
		follow.get_node("SnakeBlock").paused = false
