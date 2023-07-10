@tool

extends Node2D

## GroupDrawer draws a shape around a given set of nodes.
## By default, this includes all of the nodes in the subtree of GroupDraw's parent.
## A different set of nodes can be used for this by changing the node_getter callback.
##
## You can use GroupDrawer to e.g. show that nodes belong together in some way.

@export var color: Color = Color(1, 1, 1, 0.2)
@export var onlyInEditor: bool = true

var last_child_positions = {}

var label_nodes = [Node2D.new(), Node2D.new()]

func _ready():
	# these nodes are used to make sure that the label is covered by the polygon
	for n in label_nodes:
		add_child(n, false, INTERNAL_MODE_BACK)

func _process(_delta):
	if !(get_parent() is CanvasItem) or (onlyInEditor and !Engine.is_editor_hint()): return
	
	var child_positions = {}
	for node in Utils.all_nodes(get_parent(), true):
		child_positions[node] = node.position
	
	for node in child_positions:
		if child_positions != last_child_positions:
			last_child_positions = child_positions
			queue_redraw()
			break

func _circle(radius: float, number_of_points: int, offset = Vector2.ZERO):
	var points = []
	for i in range(number_of_points):
		points.append(Vector2(radius, 0).rotated(2 * PI * i / number_of_points) + offset)
	return points

var label_position = Vector2.ZERO

func _draw():
	var nodes = Utils.all_nodes(get_parent(), true)
	if nodes.is_empty(): return
	
	var left = INF
	var right = -INF
	var top = INF
	var bottom = -INF
	
	var node_circles = []
	for node in nodes:
		var pos = to_local(node.global_position)
		var circle = _circle(30, 20, pos)
		node_circles.append_array(circle)
		
		left = min(left, pos.x)
		right = max(right, pos.x)
		top = min(top, pos.y)
		bottom = max(bottom, pos.y)
	var hull = Geometry2D.convex_hull(PackedVector2Array(node_circles))
	
	var label = get_parent().name
	var font_size = 26
	var label_size = ThemeDB.fallback_font.get_string_size(label, HORIZONTAL_ALIGNMENT_CENTER, -1, font_size)
	label_position = Vector2(left + right - label_size.x, top + bottom + label_size.y / 2) / 2
	
	label_nodes[0].position = label_position + Vector2.UP * label_size.y / 4
	label_nodes[1].position = label_position + Vector2.RIGHT * label_size.x + Vector2.UP * label_size.y / 4
	
	draw_colored_polygon(hull, color)
	draw_string(ThemeDB.fallback_font, label_position, label, HORIZONTAL_ALIGNMENT_CENTER, -1, font_size, color)
