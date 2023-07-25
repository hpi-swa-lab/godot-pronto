extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	queue_redraw()
	pass


func _draw():
	var point1 = G.get_parent().find_child("rod_tip", true, false).position - self.position
	var point2 = G.get_parent().find_child("water_point", true, false).position - self.position
	var point3 = G.get_parent().find_child("hooka2d", true, false).position - self.position - Vector2(0,4)
	var point2_new = Vector2(point3.x, point2.y)
	

	draw_polyline([point1, point2_new, point3], Color8(135,134,146), 4)
