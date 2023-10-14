@tool
extends CheckButton

var info_box: VBoxContainer

func _ready():
	info_box = get_parent().find_child("ExportInfo") as VBoxContainer

func _enter_tree():
	pressed.connect(toggle_info_box)
	
func toggle_info_box():
	info_box.visible = not info_box.visible
