@tool
#thumb("PinJoint2D")
extends Behavior
class_name ValueBehavior

## A ValueBehavior is a [class Behavior] that allows for easier representation of single 
## float values while prototyping.

signal value_changed(value: float)

const WIDTH = 120
const BUFFER_PCT = 0.1

var value_init = false


@export_enum("Float", "Enum", "Bool") var selectType: String = "Float":
	set(val):
		selectType = val
		# todo: figure out if we want to clear certain variables here for a clean slate
		notify_property_list_changed()
		
# float variables
## Min value for the float
var float_min:float = 0.0:
	set(min):
		float_min = min
		float_value = snapped(max(min, float_value), float_step_size)

## Max value for the float
var float_max:float = 100.0:
	set(max):
		float_max = max
		float_value = snapped(min(max, float_value), float_step_size)


var float_default:float = 0
var float_step_size:float = 1:
	set(val):
		if val > 0:
			float_step_size = val
			float_value = float_value
			

var float_value:float = 0:
	set(val):
		if(!value_init):
			float_default = snapped(val, float_step_size)
			value_init = true
		float_value = snapped(val, float_step_size)
		_reset_limits()
		notify_property_list_changed()
		_handle_update_value(float_value)

# enum variables
var enum_choices: Array[String] = [""]:
	set(val):
		enum_choices = val
		notify_property_list_changed()

var enum_default_index: int

var enum_value: String:
	set(val):
		#print("Store name: " + name)
		if(!value_init):
			enum_default_index = enum_choices.find(val)
			#print("Setting default for Enum index to: " + val + " with index: "  + str(enum_default_index))
			value_init = true
		#print("Updateting Enum value to: " + val)
		enum_value = val
		notify_property_list_changed()
		_handle_update_value(enum_value)



# bool variable
var bool_value: String = "TRUE":
	set(val):
		if(!value_init):
			#print("Setting default for Bool value to: " + str(val))
			bool_default = val == "TRUE"
			value_init = true
		bool_value = val
		_bool_value = val == "TRUE"
		_handle_update_value(_bool_value)


var _bool_value: bool

var bool_default: bool

## Resets the min and max if the value is being set as a number
func _reset_limits():
	if float_value > float_max:
		var buffer = BUFFER_PCT * (float_value - float_min)
		float_max = snapped(float_value + buffer, float_step_size)
		print("Adapted float_max value")
	elif float_value < float_min:
		var buffer = BUFFER_PCT * (float_max - float_value)
		float_min = snapped(float_value - buffer, float_step_size)
		print("Adapted float_min value")

func _handle_update_value(value):
	#print("Updating Value to:" + str(value))
	if not is_inside_tree(): await ready
	G.put(name, value)
	value_changed.emit(value)
	queue_redraw()
	#print("Updated Value: " + name + " to: " + str(value))
		
		
# conditional exporting is not yet supported through annotations in Godot 4
# therefore we manupilate the property list manually as described here:
# https://github.com/godotengine/godot-proposals/issues/1056
func _get_property_list():
	var properties = []
	if selectType == "Float":
		properties.append({
			"name": "float_min",
			"type": TYPE_FLOAT,
		})
		properties.append({
			"name": "float_max",
			"type": TYPE_FLOAT,
		})
		properties.append({
			"name": "float_value",
			"type": TYPE_FLOAT,
		})
		properties.append({
			"name": "float_step_size",
			"type": TYPE_FLOAT,
		})
	elif selectType == "Enum":
		properties.append({
			"name": "enum_choices",
			"class_name": &"", "type": 28, "hint": 23, "hint_string": "4:String", "usage": 4102
			# extracted by checking export of regular array
		})
		properties.append({
			"name": "enum_value",
			"type": TYPE_STRING,
			'hint': PROPERTY_HINT_ENUM,
			'hint_string': ",".join(enum_choices)
		})
	elif selectType == "Bool":
		properties.append({
			"name": "bool_value",
			"type": TYPE_STRING,
			'hint': PROPERTY_HINT_ENUM,
			'hint_string': "TRUE,FALSE"
		})
	else:
		push_error("Invalid Type (" + selectType + ") selected for AdvancedValue " + str(self.name))			
	return properties

func _ready():
	super._ready()
	renamed.connect(queue_redraw)
	G.put(name, float_value)

func _forward_canvas_draw_over_viewport(viewport_control: Control):
	var center = get_viewport_transform() * get_canvas_transform() * global_position
	viewport_control.draw_line(center + Vector2(-WIDTH / 2, 0), center + Vector2(WIDTH / 2, 0), Color.WHITE, 3, true)
	super._forward_canvas_draw_over_viewport(viewport_control)

func handles():
	return [Handles.SetPropHandle.new(
		Vector2(remap(float_value, float_min, float_max, -WIDTH / 2, WIDTH / 2), 0),
		Utils.icon_from_theme("EditorHandle", self),
		self,
		"value",
		func (val): return remap(val.x, -WIDTH / 2, WIDTH / 2, float_min, float_max),
		false)]

func _draw():
	super._draw()
	
	if Engine.is_editor_hint() and is_active_scene():
		var str = name + " = " + String.num(float_value, 2)
		var font := ThemeDB.fallback_font
		var text_size = 4
		draw_string(font,
			Vector2(font.get_string_size(str, HORIZONTAL_ALIGNMENT_CENTER, -1, text_size).x / -2, 22),
			str,
			HORIZONTAL_ALIGNMENT_CENTER,
			-1,
			text_size)
			
func _init():
	for info in get_property_list():
		if info.name == "enum_choices_2":
			print(info)			

class DropPropertyPrompt extends ColorRect:
	var editor_interface#: EditorInterface (does not work in export)
	
	func _init(editor_interface):
		for info in get_property_list():
			if info.name == "enum_choices_2":
				print(info)
		self.editor_interface = editor_interface
		
		color = Color.WHITE
		custom_minimum_size = Vector2(200, 30)
		
		var l = Label.new()
		l.text = "Drop here to create slider"
		add_child(l)
	
	func _can_drop_data(at_position, data):
		# the prompt is only displayed if we have a drag operation with a valid object
		return true
	
	func empty_script(a: Array, expr: String, return_value: bool):
		var script := ConnectionScript.new(a, return_value, expr)
		return script
	
	func _drop_data(at_position, data):
		var root = editor_interface.get_edited_scene_root()
		var current = data["object"].get(data["property"])
		
		var v = ValueBehavior.new()
		v.float_min = min(0.0, current)
		v.float_max = max(1.0, current)
		v.float_value = current
		v.name = data["property"]
		v.position = Vector2(50, 50)
		data["object"].add_child(v)
		v.owner = root
		
		Connection.connect_target(v, "value_changed", "..", "set", [empty_script(["value"], "\"%s\"" % [data["property"]], true), empty_script(["value"], "value", true)], [], empty_script(["value"], "true", true))
		
#		var b = BindBehavior.new()
#		b.to_prop = data["property"]
#		b.name = "bind_" + b.to_prop
#		b.position = Vector2(100, 50)
#		b.convert = "G.at('{0}')".format([data["property"]])
#		data["object"].add_child(b)
#		b.owner = root
