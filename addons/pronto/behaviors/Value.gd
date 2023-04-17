@tool
#thumb("PinJoint2D")
extends Behavior

signal value_changed(value: float)

const WIDTH = 120

@export var from = 0.0
@export var to = 1.0
@export var value = 0.0:
	set(val):
		value = clamp(val, from, to)
		value_changed.emit(value)
		G.put(name, value)
		queue_redraw()

func _ready():
	super._ready()
	renamed.connect(queue_redraw)
	G.put(name, value)

func _forward_canvas_draw_over_viewport(viewport_control: Control):
	var center = get_viewport_transform() * get_canvas_transform() * global_position
	viewport_control.draw_line(center + Vector2(-WIDTH / 2, 0), center + Vector2(WIDTH / 2, 0), Color.WHITE, 3, true)
	super._forward_canvas_draw_over_viewport(viewport_control)

func handles():
	return [Handles.SetPropHandle.new(
		Vector2(remap(value, from, to, -WIDTH / 2, WIDTH / 2), 0),
		Utils.icon_from_theme("EditorHandle", self),
		self,
		"value",
		func (val): return remap(val.x, -WIDTH / 2, WIDTH / 2, from, to),
		false)]

func _draw():
	super._draw()
	
	if Engine.is_editor_hint():
		var str = name + " = " + String.num(value, 2)
		var font := ThemeDB.fallback_font
		var text_size = 4
		draw_string(font,
			Vector2(font.get_string_size(str, HORIZONTAL_ALIGNMENT_CENTER, -1, text_size).x / -2, 12),
			str,
			HORIZONTAL_ALIGNMENT_CENTER,
			-1,
			text_size)
