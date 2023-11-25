extends Node

var current_key_code = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()  # Initialize the random number generator
#	current_key_code = get_random_key_code()
#	print("Press the key: ", key_code_to_char(current_key_code))

signal key_pressed()
signal change_text(current_key_code: Variant)
signal wrong_key_pressed()

func get_random_key_code():
	return KEY_A + randi() % 26

# Called every frame
func _process(delta):
	if Input.is_key_pressed(current_key_code):
#		print("Correct key pressed: ", key_code_to_char(current_key_code))
#		current_key_code = get_random_key_code()
#		print("Press the next key: ", key_code_to_char(current_key_code))
		key_pressed.emit()

func get_new_key():
	current_key_code = get_random_key_code()
	change_text.emit(current_key_code)
