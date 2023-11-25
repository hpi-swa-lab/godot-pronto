@tool
extends Label


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func change_text(new_text: String):
	text = new_text

func key_code_to_char(key_code):
	# Convert the Godot key code to a character
	return char(key_code - KEY_A + 65)  # 97 is ASCII for 'a'

func set_text_key_code(current_key_code: Variant):
	change_text("Press: " + key_code_to_char(current_key_code))
	
func set_text_key_pressed():
	change_text("")
	
