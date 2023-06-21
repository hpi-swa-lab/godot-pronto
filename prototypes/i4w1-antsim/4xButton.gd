extends Button


# Called when the node enters the scene tree for the first time.
func _ready():
	self.pressed.connect(self.handle_pressed)

func handle_pressed():
	Engine.time_scale = 4.0


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
