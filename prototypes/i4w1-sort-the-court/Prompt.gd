extends StaticBody2D

const config = preload("res://prototypes/i4w1-sort-the-court/promts.json")

var dialogs: Dictionary = {}
var available_prompts = []
var current_prompt: Dictionary = {}

func register_yes():
	pass

func register_no():
	pass

func register_acknowledge():
	pass

# Called when the node enters the scene tree for the first time.
func _ready():
	dialogs = config.get("persons")
	
	var start_prompt = config.get("start_prompt")
	
	available_prompts = [
		dialogs.get(start_prompt.get("person")).get("dialogs").get(start_prompt.get("dialog"))
	]


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
