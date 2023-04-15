@tool
extends TextureRect

@export var key: String

signal down
signal up
signal toggled(down: bool)

func _ready():
	Utils.setup(self)

func _input(event):
	if event is InputEventKey and event.as_text_keycode() == key:
		if event.pressed:
			down.emit()
			toggled.emit(true)
		else:
			up.emit()
			toggled.emit(false)
