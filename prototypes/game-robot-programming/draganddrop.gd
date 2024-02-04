extends Area2D

var dragging: bool = false

signal dragsignal


# Called when the node enters the scene tree for the first time.
func _ready():
	dragsignal.connect(self._set_drag_pc)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if dragging:
		var mousepos = get_viewport().get_mouse_position()
		self.position = mousepos
		
func _set_drag_pc():
	dragging = !dragging

func _on_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			if Global.event_is_handled(event):
				return
			dragsignal.emit()
			Global.note_event(event)
		elif event.button_index == MOUSE_BUTTON_LEFT and !event.pressed:
			if dragging:
				dragsignal.emit()
