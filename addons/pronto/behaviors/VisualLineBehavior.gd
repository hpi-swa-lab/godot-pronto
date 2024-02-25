@tool
#thumb("EditBezier")
extends Behavior
class_name VisualLineBehavior
## The VisualLineBehavior is a [class Behavior] that allows to draw a straight line
## between two nodes.

## The starting node of the line
@export var from: Node2D

## The target node of the line
@export var to: Node2D

## The color that the line will be drawn in
@export var line_color = Color.WHITE:
	set(v):
		line_color = v
		queue_redraw()

## The thickness of the line
@export var line_width = 2:
	set(v):
		line_width = v
		queue_redraw()

var line_length: float = 0

func _ready():
	super._ready()

func _process(delta):
	queue_redraw()

func show_icon():
	return false

func _draw():
	super._draw()
	
	if (not from or not to):
		return
	
	draw_line(
		from.get_global_position() - get_global_position(), 
		to.get_global_position() - get_global_position(), 
		line_color, 
		line_width, 
		true
	)
	
	line_length = from.get_global_position().distance_to(to.get_global_position())

func get_line_length():
	return line_length
