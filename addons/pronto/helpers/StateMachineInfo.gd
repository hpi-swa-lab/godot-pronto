@tool
extends Node2D

@export var color: Color = Color(1, 1, 1, 0.2)
@export var triggered_color: Color = Color.PALE_GREEN

var processing_trigger = false

@export var onlyInEditor: bool = true

# Called when the node enters the scene tree for the first time.
func _ready():
	redraw_periodically()
	if get_parent() is StateMachineBehavior:
		var parent: StateMachineBehavior = get_parent()
		parent.triggered.connect(redraw_with_trigger)

func redraw_periodically():
	while is_inside_tree():
		await get_tree().create_timer(1).timeout
		if not processing_trigger:
			queue_redraw()

# TODO: This does not currently work. Why? Is only called for "ε" trigger
var active_trigger = ""
func redraw_with_trigger(trigger):
	if trigger != "ε":
		active_trigger = trigger
		processing_trigger = true
		queue_redraw()
		await get_tree().create_timer(0.5).timeout
		queue_redraw()
		processing_trigger = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

var label_position = Vector2.ZERO

func get_label_position():
	var states = get_parent().get_children()
	if states.size() == 0: return Vector2(150,0)
	var max_x = 0
	for node in states:
		max_x = max(node.position.x/2, max_x)
	return Vector2(max_x + 150, 0)

func _draw():
	if not get_parent() is StateMachineBehavior: return
	var state_machine: StateMachineBehavior = get_parent()
	var font_size = 10

	
	var label = "Triggers:"
	var label_size = ThemeDB.fallback_font.get_string_size(label, HORIZONTAL_ALIGNMENT_CENTER, -1, font_size)
	label_position = get_label_position()
	draw_string(ThemeDB.fallback_font, label_position, label, HORIZONTAL_ALIGNMENT_CENTER, -1, font_size, color)
	for trigger in state_machine.triggers:
		label = trigger
		label_position.y += label_size.y
		var label_color = triggered_color if trigger == active_trigger else color
		draw_string(ThemeDB.fallback_font, label_position, label, HORIZONTAL_ALIGNMENT_CENTER, -1, font_size, label_color)

