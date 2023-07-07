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

func _process(_delta):
	if !(get_parent() is CanvasItem) or (onlyInEditor and !Engine.is_editor_hint()): return
	
	var child_positions = {}
	for node in Utils.all_nodes(get_parent()):
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

func _draw():
	var nodes = Utils.all_nodes(get_parent())
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
	draw_colored_polygon(hull, color)
	draw_string(ThemeDB.fallback_font, Vector2(left + right, top + bottom) / 2, get_parent().name, 0, -1, 26, color)
