extends StaticBody2D

@onready var _follow: PathFollow2D = get_parent()
@export var paused: bool = true
var is_finished: bool = false

func _physics_process(delta):
	if (paused):
		return
	if is_finished:
		get_node("Placeholder").color = Color.DARK_GREEN
		return
	var speed = G.at("SnakeSpeed")
	_follow.set_progress(_follow.get_progress() + speed * delta)
	if _follow.get_progress_ratio() >= 1:
		is_finished = true
		for follow in _follow.get_parent().get_children():
			follow.get_node("SnakeBlock").is_finished = true
			var clock = follow.get_node("Clock")
			clock.duration_seconds = G.at("SnakeDespawnTime")
			clock.reset_and_start()
			
func activate_snake():
	if not paused:
		return
	for follow in _follow.get_parent().get_children():
		follow.get_node("SnakeBlock").paused = false
