extends Button


# Called when the node enters the scene tree for the first time.
func _ready():
	self.pressed.connect(_start)
	
	
func _start():
	G.get_parent().find_child("Player", true, false).play("fishing")
	G.get_parent().find_child("menu", true, false).exit("")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
