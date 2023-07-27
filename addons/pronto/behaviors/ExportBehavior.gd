@tool
#thumb("Save")
extends Behavior
class_name ExportBehavior

@export var enable: bool = true
@export_category("Game Info")
@export var title: String = "<Title>"
@export var authors: PackedStringArray = ["<Author>"]
@export_multiline var description = ""

@export_category("Export")
@export var take_screenshot: bool = true
@export var wait_seconds: int = 1

var timer: Timer

func _ready():
	super._ready()
	if not enable: return;
	# start export timer
	timer = Timer.new()
	timer.connect("timeout", _export) 
	add_child(timer)
	timer.one_shot = true
	timer.wait_time = max(1, wait_seconds) # wait at least 1s
	timer.start()

func _export():
	var scene_path = get_tree().current_scene.scene_file_path
	var tmp = scene_path.split("/")
	var scene_name = tmp[tmp.size()-1];
	var export_path = scene_path.rstrip(scene_name)
	_take_screenshot(export_path)
	_create_game_json(export_path)
	
func _take_screenshot(export_path):
	var vpt = get_viewport()
	var tex = vpt.get_texture()
	tex.get_image().save_png(export_path + "thumbnail.png")
	print("screenshot taken")
	
func _create_game_json(export_path):
	var game_dict = {
		"title": title
	}
	if not authors.is_empty():
		game_dict["authors"] = authors
	if not description.is_empty():
		game_dict["description"] = description
	if take_screenshot:
		game_dict["thumbnailType"] = "png"
	
	var path = export_path + "game_info.json"
	var file = FileAccess.open(path, FileAccess.WRITE)

	file.store_string(JSON.stringify(game_dict, "\t"))
	file = null
	print("export finished")
