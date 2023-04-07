@tool
extends HBoxContainer

var is_last = false:
	set(value):
		is_last = value
		$Separator.visible = !is_last

var arg_name = "":
	set(value):
		arg_name = value
		$LineEdit.placeholder_text = arg_name

var text = "":
	set(value):
		$LineEdit.text = value
	get:
		return $LineEdit.text
