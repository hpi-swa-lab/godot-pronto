extends Node2D

var tile_map: TileMap
var car: CharacterBody2D
# Called when the node enters the scene tree for the first time.
func _ready():
	tile_map = get_parent().find_child("TileMap", true, false)
	car = get_parent().get_parent().find_child("Car", true, false)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var car_pos = tile_map.local_to_map(car.position*4)
	if tile_map.get_cell_source_id(0, car_pos) == -1:
		print("Car left the track")
		get_tree().reload_current_scene()
