extends Button
signal clicked


# Called when the node enters the scene tree for the first time.
func _ready():
	self.pressed.connect(_emit_pressed)

func _emit_pressed():
	print("Ending player turn")
	G.get_parent().get_node("i5w1-modular-enemies/STATE/player_turn").exit(1)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
