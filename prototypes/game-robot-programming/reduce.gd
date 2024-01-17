extends Button

func reduce():
	$"../CollisionShape2D".shape.size.y -= 10
	$"../CollisionShape2D".position.y -= 5
	$"../Polygon2D".polygon[0].y -= 10
	$"../Polygon2D".polygon[3].y -= 10
