extends Node

var current_key_code = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()  
	changed_difficulty.emit(currentDifficulty_to_string())
	# Initialize the random number generator
#	current_key_code = get_random_key_code()
#	print("Press the key: ", key_code_to_char(current_key_code))

signal key_pressed()
signal change_text(current_key_code: Variant)
signal changed_difficulty(to: String)

var fluteKeysEasy = [KEY_UP, KEY_DOWN, KEY_LEFT, KEY_RIGHT]
var fluteKeysMedium = [KEY_U, KEY_I, KEY_O, KEY_J, KEY_K, KEY_L]

enum Difficulty {
	easy = 0,
	medium = 1,
	hard = 2
}

var currentDifficulty = Difficulty.easy

func get_random_key_code():
	if currentDifficulty == Difficulty.easy:
		return fluteKeysEasy[randi() % 4]
	elif currentDifficulty == Difficulty.medium:
		return fluteKeysMedium[randi() % 6]
	elif currentDifficulty == Difficulty.hard:
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

func change_difficulty():
	currentDifficulty = (currentDifficulty + 1) % 3
	changed_difficulty.emit(currentDifficulty_to_string())
	
func currentDifficulty_to_string():
	return Difficulty.keys()[currentDifficulty]

func _on_difficulty_pressed():
	change_difficulty()
