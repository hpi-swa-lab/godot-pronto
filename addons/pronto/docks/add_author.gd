@tool
extends Button

var authors_box: VBoxContainer

func _ready():
	authors_box = get_parent().get_parent().find_child("Authors") as VBoxContainer

func _enter_tree():
	pressed.connect(add_author)
	
func add_author():
	var row = HBoxContainer.new()
	var label = Label.new()
	label.text = "Author" + str(authors_box.get_child_count() + 1) + ": "
	var name = TextEdit.new()
	name.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(label)
	row.add_child(name)
	authors_box.add_child(row)
