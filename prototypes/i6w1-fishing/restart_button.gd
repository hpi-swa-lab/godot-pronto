extends Button


func _ready():
	self.pressed.connect(_start)
	
func _start():
	G.get_parent().find_child("score", true, false).exit("")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
