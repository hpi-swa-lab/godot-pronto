extends Button

@export var speed: float = 1.0
# Called when the node enters the scene tree for the first time.
func _ready():
	self.pressed.connect(self.handle_pressed)

func handle_pressed():
	Engine.time_scale = speed

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
