@tool
#thumb("PinJoint2D")
extends Behavior
class_name Value

signal value_changed(value: float)

const WIDTH = 120

@export var from = 0.0
@export var to = 1.0
@export var step_size = 1.0:
	set(val):
		if val and val > 0:
			step_size = val

@export var value = 0.0:
	set(val):
		value = clamp(float(round(val/step_size)*step_size), from, to)
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
	
	if Engine.is_editor_hint() and is_active_scene():
		var str = name + " = " + String.num(value, 2)
		var font := ThemeDB.fallback_font
		var text_size = 4
		draw_string(font,
			Vector2(font.get_string_size(str, HORIZONTAL_ALIGNMENT_CENTER, -1, text_size).x / -2, 12),
			str,
			HORIZONTAL_ALIGNMENT_CENTER,
			-1,
			text_size)

class DropPropertyPrompt extends ColorRect:
	var editor_interface: EditorInterface
	
	func _init(editor_interface):
		self.editor_interface = editor_interface
		
		color = Color.WHITE
		custom_minimum_size = Vector2(200, 30)
		
		var l = Label.new()
		l.text = "Drop here to create slider"
		add_child(l)
	
	func _can_drop_data(at_position, data):
		# the prompt is only displayed if we have a drag operation with a valid object
		return true
	
	func _drop_data(at_position, data):
		var root = editor_interface.get_edited_scene_root()
		var current = data["object"].get(data["property"])
		
		var v = Value.new()
		v.from = min(0.0, current)
		v.to = max(1.0, current)
		v.value = current
		v.name = data["property"]
		v.position = Vector2(50, 50)
		data["object"].add_child(v)
		v.owner = root
		
		var b = Bind.new()
		b.to_prop = data["property"]
		b.name = "bind_" + b.to_prop
		b.position = Vector2(100, 50)
		b.convert = "G.at('{0}')".format([data["property"]])
		data["object"].add_child(b)
		b.owner = root
