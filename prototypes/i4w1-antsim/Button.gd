extends Button


# Called when the node enters the scene tree for the first time.
func _ready():
	self.pressed.connect(self.handle_pressed)


func handle_pressed():
	get_parent().get_tree().paused = false
	self.visible = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
