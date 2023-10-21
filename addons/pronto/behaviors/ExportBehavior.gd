@tool
#thumb("Save")
extends Behavior
class_name ExportBehavior

const DEFAULT_TITLE = "<Title>"
const DEFAULT_AUTHOR = "<Author>"

## The display title of the game
@export var title: String = DEFAULT_TITLE:
	set(value):
		title = value
		update_configuration_warnings()

## All authors of the game
@export var authors: PackedStringArray = [DEFAULT_AUTHOR]:
	set(value):
		authors = value
		update_configuration_warnings()

## The description of the game
@export_multiline var description = "":
	set(value):
		description = value
		update_configuration_warnings()

## Settings for the Thumbnail
@export_category("Thumbnail")

## If true, a screenshot will be taken after a delay and saved as thumbnail.png
@export var take_screenshot: bool = true

## The delay until the screenshot is taken
@export var wait_seconds: int = 1

var timer: Timer
var export_path

func _ready():
	super._ready()
	
	if OS.has_feature("release") or Engine.is_editor_hint(): return

	var scene_path = get_tree().current_scene.scene_file_path
	var tmp = scene_path.split("/")
	var scene_name = tmp[tmp.size()-1];
	export_path = scene_path.rstrip(scene_name)

	_create_game_json()

	if not take_screenshot: return
	# start thumbnail timer
	timer = Timer.new()
	timer.connect("timeout", _take_screenshot) 
	add_child(timer)
	timer.one_shot = true
	timer.wait_time = max(1, wait_seconds) # wait at least 1s
	timer.start()
	
func _take_screenshot():
	var vpt = get_viewport()
	var tex = vpt.get_texture()
	tex.get_image().save_png(export_path + "thumbnail.png")
	print("screenshot taken")
	
func _create_game_json():
	var game_dict = {
		"title": title,
		"time": Time.get_date_string_from_system()
	}
	if not authors.is_empty():
		game_dict["authors"] = authors
	if not description.is_empty():
		game_dict["description"] = description
	
	var path = export_path + "game_info.json"
	var file = FileAccess.open(path, FileAccess.WRITE)

	file.store_string(JSON.stringify(game_dict, "\t"))
	file = null

func _get_configuration_warnings():
	var message = []
	if not self.name == "ExportBehavior":
		message.append("ExportBehavior should not be renamed!")
	if title == DEFAULT_TITLE:
		message.append("Please enter the title of your game.")
	if authors.size() == 0 or authors[0] == DEFAULT_AUTHOR:
		message.append("Please enter the authors of your game.")
	if description == "":
		message.append("Please enter a description for your game.")
	return message	
