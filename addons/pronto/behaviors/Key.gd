@tool
#thumb("KeyboardPhysical")
extends Behavior
class_name Key

@export var key: String

var is_pressed: bool = false
var pressed_since: int = 0

signal down
signal up
signal toggled(down: bool)
signal pressed
signal just_down
signal just_up(duration: int)

func _process(_delta):
	super._process(_delta)
	if is_pressed:
		pressed.emit()

func lines():
	return super.lines() + [Lines.BottomText.new(self, str(key))]

func _input(event):
	if event is InputEventKey and event.as_text_keycode() == key and not event.echo:
		if event.pressed and !is_pressed:
			pressed_since = Time.get_ticks_msec()
			just_down.emit()
		if !event.pressed and is_pressed:
			just_up.emit(Time.get_ticks_msec() - pressed_since)
			pressed_since = 0
		
		is_pressed = event.pressed
		
		if is_pressed:
			down.emit()
			toggled.emit(true)
		else:
			up.emit()
			toggled.emit(false)
