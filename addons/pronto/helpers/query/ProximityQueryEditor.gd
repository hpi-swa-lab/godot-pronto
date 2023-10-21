@tool
extends HBoxContainer

signal changed_query

var query: ProximityQuery

func set_query(q: ProximityQuery):
	query = q

func set_radius(radius):
	$SpinBox.value = radius

func _change(value):
	query.radius = value
	changed_query.emit()
