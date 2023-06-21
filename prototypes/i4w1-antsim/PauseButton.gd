extends Button


# Called when the node enters the scene tree for the first time.
func _ready():
	self.pressed.connect(self.handle_pressed)


func handle_pressed():
	if get_parent().get_parent().find_child("StartLabel"):
		get_parent().get_parent().find_child("StartLabel").queue_free()
	get_parent().get_tree().paused = not get_parent().get_tree().paused


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
