@tool
extends Button

var authors_box: VBoxContainer

func _ready():
	authors_box = get_parent().get_parent().find_child("Authors") as VBoxContainer

func _enter_tree():
	pressed.connect(reset_authors)
	
func reset_authors():
	while authors_box.get_child_count() > 1:
		var last = authors_box.get_child(authors_box.get_child_count()-1)
		authors_box.remove_child(last)
		last.queue_free()
