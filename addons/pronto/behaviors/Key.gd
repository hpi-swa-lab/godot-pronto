@tool
#thumb("KeyboardPhysical")
extends Behavior

@export var key: String

var is_pressed: bool = false

signal down
signal up
signal toggled(down: bool)
signal pressed
signal just_down
signal just_up

func _process(_delta):
	super._process(_delta)
	if is_pressed:
		pressed.emit()

func _input(event):
	if event is InputEventKey and event.as_text_keycode() == key:
		if event.pressed and !is_pressed:
			just_down.emit()
		if !event.pressed and is_pressed:
			just_up.emit()
		
		is_pressed = event.pressed
		
		if is_pressed:
			down.emit()
			toggled.emit(true)
		else:
			up.emit()
			toggled.emit(false)
