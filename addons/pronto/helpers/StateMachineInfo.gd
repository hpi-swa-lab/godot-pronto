@tool
extends Node2D

@export var color: Color = Color(1, 1, 1, 0.2)
@export var onlyInEditor: bool = true

# Called when the node enters the scene tree for the first time.
func _ready():
	redraw_periodically()

func redraw_periodically():
	while is_inside_tree():
		await get_tree().create_timer(1).timeout
		queue_redraw()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

var label_position = Vector2.ZERO

func _draw():
	if not get_parent() is StateMachineBehavior: return
	var state_machine: StateMachineBehavior = get_parent()
	var font_size = 10

	
	var label = "Triggers:"
	var label_size = ThemeDB.fallback_font.get_string_size(label, HORIZONTAL_ALIGNMENT_CENTER, -1, font_size)
	label_position = Vector2(get_parent().position.x, get_parent().position.y)
	draw_string(ThemeDB.fallback_font, label_position, label, HORIZONTAL_ALIGNMENT_CENTER, -1, font_size, color)
	for trigger in state_machine.triggers:
		label = trigger
		label_position.y += label_size.y
		draw_string(ThemeDB.fallback_font, label_position, label, HORIZONTAL_ALIGNMENT_CENTER, -1, font_size, color)

