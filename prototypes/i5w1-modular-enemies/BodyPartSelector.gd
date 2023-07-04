extends Button
var target_name = ""

# Called when the node enters the scene tree for the first time.
func _ready():
	self.pressed.connect(_emit_pressed)
	target_name = self.get_parent().name

func _emit_pressed():
	if G.at("Target") != target_name:
		for child in get_parent().get_parent().get_children():
				(child as PlaceholderShape).color = Color.WHITE
				
		G.put("Target", target_name)
		get_parent().color = Color.FIREBRICK
		print(target_name + " selected")
	else:
		G.put("Target", "None")
		get_parent().color = Color.WHITE
		print(target_name + " deselected")
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
