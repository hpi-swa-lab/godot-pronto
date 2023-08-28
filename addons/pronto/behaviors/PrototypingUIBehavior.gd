@tool
#thumb("Grid")
extends Behavior
class_name PrototypingUIBehavior

## Add to your scene to edit properties while in-game.

## If true, the PrototypingUI will be visible in the export
@export var show_in_export = true

## If [code]true[/code], all values in the scene are added to the menu (if they are visible) [br]
## If [code]false[/code], only children ValueBehaviors are added to the menu (if they are visible)
@export var include_all_values = false

## If [code]true[/code] the PrototypingUI starts minimized.
@export var minimized: bool = false

var panel: PanelContainer
var muted_gray: Color = Color(0.69, 0.69, 0.69, 1)
var vbox = VBoxContainer.new()
var header = HBoxContainer.new()
var expanded_size = Vector2(0,0)

# Called when the node enters the scene tree for the first time.
func _ready():
	super._ready()
	
	if OS.has_feature("release") and not show_in_export: return
	
	#if not is_instance_of(self.get_parent(), PanelContainer):
	#	push_error("Prototyping UI needs to be the child of a PanelContainer.")
	#	return
	panel = self.get_parent()
	expanded_size = panel.size
	
	var scrollContainer = ScrollContainer.new()
	
	vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	vbox.size_flags_vertical = Control.SIZE_EXPAND_FILL
	
	var nodes_to_add = []
	
	if include_all_values:
		nodes_to_add = _get_valid_children()
	else:
		nodes_to_add = _get_valid_children(self)
	
	for childNode in nodes_to_add:
		maybe_add_config(childNode)
	
	scrollContainer.add_child(vbox)
	scrollContainer.size_flags_vertical = Control.SIZE_EXPAND_FILL
	
	
	var outerVbox = VBoxContainer.new()
	outerVbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	outerVbox.size_flags_vertical = Control.SIZE_EXPAND_FILL
	header = create_header()
	outerVbox.add_child(header)
	outerVbox.add_child(scrollContainer)
	
	# adding through deferred call as it might fail otherwise
	#outerVbox.size = Vector2(max(vbox.size.x,header.size.x), vbox.size.y + header.size.y+100)
	
	panel.add_child.call_deferred(outerVbox)
	# print("Prototype UI generated successfully")
	
func maybe_add_config(node: Node):
	if is_instance_of(node, CodeBehavior):
		if not node.visible: return # Hide values that are hidden in the Editor
		vbox.add_child(create_ui_for_code(node))
		return true
	elif is_instance_of(node, ValueBehavior):
		if not node.visible: return # Hide values that are hidden in the Editor
		vbox.add_child(create_ui_for_value(node))
		return true
	return false

func _node_is_valid(node):
	return is_instance_of(node, CodeBehavior) or is_instance_of(node, ValueBehavior)

func _get_valid_children(node = get_tree().root):
	var child_nodes = []
	for child in node.get_children():
		if _node_is_valid(child):
			child_nodes.push_back(child)
		child_nodes.append_array(_get_valid_children(child))
	return child_nodes

func create_ui_for_value(value: ValueBehavior):
	if value.selectType == "Float":
		return create_ui_slider_for_value_float(value)
	elif value.selectType == "Enum":
		return create_ui_for_value_enum(value)
	elif value.selectType == "Bool":
		return create_ui_for_value_bool(value)
	return
	
	
	
func create_ui_for_value_enum(value: ValueBehavior):
	var name = value.name
	var label = Label.new()
	label.text = name + ":"
	label.vertical_alignment = VERTICAL_ALIGNMENT_TOP
	
	var hbox = HBoxContainer.new()
	var optionButton = OptionButton.new()
	optionButton.focus_mode = 0
	
	var index = 0
	for item in value.enum_choices :
		optionButton.add_item(item,index)
		index = index + 1

	optionButton.select(value.enum_default_index)
	optionButton.item_selected.connect(handle_value_enum_change.bind(value,optionButton))
	
	var reset_button = Button.new()
	reset_button.text = "⟳"
	reset_button.focus_mode = 0
	reset_button.button_down.connect(handle_value_enum_change.bind(value.enum_default_index, value, optionButton))
	
	hbox.add_child(label)
	hbox.add_child(optionButton)
	hbox.add_child(reset_button)
	
	
	return hbox
	
func create_ui_for_value_bool(value: ValueBehavior):
	
	var name = value.name
	var label = Label.new()
	label.text = name + ":"
	label.vertical_alignment = VERTICAL_ALIGNMENT_TOP
	
	var hbox = HBoxContainer.new()
	var optionButton = OptionButton.new()
	optionButton.focus_mode = 0
	
	
	optionButton.add_item("FALSE", 0)
	optionButton.add_item("TRUE", 1)
	
	#print("Bool Value String: " + value.bool_value)
	#print("Bool Value Bool: " + str(value._bool_value))
	if(value.bool_value == "TRUE"):
		optionButton.select(1)
	else:
		optionButton.select(0)
	
	#hslider.value_changed.connect(handle_update_value_float_change.bind(value))
	optionButton.item_selected.connect(handle_value_bool_change.bind(value, optionButton))
	
	var reset_button = Button.new()
	reset_button.text = "⟳"
	reset_button.focus_mode = 0
	var reset_index: int
	if value.bool_value == "TRUE":
		reset_index = 1
	else:
		reset_index = 0
	reset_button.button_down.connect(handle_value_bool_change.bind(reset_index, value, optionButton))
	
	hbox.add_child(label)
	hbox.add_child(optionButton)
	hbox.add_child(reset_button)
	return hbox
	
func create_ui_for_code(code: CodeBehavior):
	var button = Button.new()
	button.text = code.name
	button.focus_mode = 0
	button.pressed.connect(code.execute.bind(code.arguments))
	return(button)
	
	
func create_ui_slider_for_value_float(value: ValueBehavior):
	var name = value.name
	
	var hbox = HBoxContainer.new()
	var middle_vbox = VBoxContainer.new()
	var lower_hbox = HBoxContainer.new()
	var name_vbox = VBoxContainer.new()
	name_vbox.size_flags_vertical = Control.SIZE_SHRINK_BEGIN


	# value name label
	var label = Label.new()
	label.text = name + ":"
	label.vertical_alignment = VERTICAL_ALIGNMENT_TOP
	name_vbox.add_child(label)
	
	# value min label
	var label_min = Label.new()
	label_min.text = str(value.float_from)
	label_min.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label_min.add_theme_color_override("font_color",muted_gray)
	
	# value max label
	var label_max = Label.new()
	label_max.text = str(value.float_to)
	label_max.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label_max.add_theme_color_override("font_color",muted_gray)
	
	var current_vbox = VBoxContainer.new()
	current_vbox.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
	
	# current value label
	var label_current = Label.new()
	label_current.text = str(value.float_value)
	label_current.vertical_alignment = VERTICAL_ALIGNMENT_TOP
	current_vbox.add_child(label_current)

	lower_hbox.add_child(label_min)
	lower_hbox.add_spacer(false)
	lower_hbox.add_child(label_max)
	lower_hbox.visible = false
	
	# slider 
	var hslider = HSlider.new()
	hslider.min_value = value.float_from
	hslider.max_value = value.float_to
	hslider.step = value.float_step_size
	#print("Float Value at init: " + str(value.float_value))
	hslider.value = value.float_value
	
	# setting growth flags so that the slider resized to parent container
	hslider.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hslider.size_flags_vertical = Control.SIZE_SHRINK_CENTER

	# setting focus mode to ignore keyboard input
	hslider.focus_mode = Slider.FOCUS_NONE
	# signal | this potentially fires very often during dragging of the slider
	hslider.value_changed.connect(handle_update_value_float_change.bind(value,label_current, hslider))
	# fancy ui signals
	hslider.drag_started.connect(_handle_slider_drag_start.bind(lower_hbox))
	hslider.drag_ended.connect(_handle_slider_drag_end.bind(lower_hbox))
	
	var reset_button = Button.new()
	reset_button.text = "⟳"
	reset_button.focus_mode = 0
	reset_button.button_down.connect(handle_update_value_float_change.bind(value.float_default,value,label_current,hslider))
	
	middle_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	middle_vbox.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
	middle_vbox.add_child(hslider)
	middle_vbox.add_child(lower_hbox)
	
	
	# adding to node tree
	hbox.add_child(name_vbox)
	hbox.add_child(middle_vbox)
	hbox.add_child(current_vbox)
	hbox.add_child(reset_button)
	return hbox

func create_minimizing_button():
	var button = Button.new()
	button.text = "−"
	button.pressed.connect(handle_size_button_click.bind(button))
	if minimized:
		handle_size_button_click(button, true)
	return button
	

func create_header():
	var hbox = HBoxContainer.new()
	var text = Label.new()
	text.text = self.name
	hbox.add_child(create_minimizing_button())
	hbox.add_child(text)
	hbox.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
	return hbox

func handle_size_button_click(button: Button, initial: bool = false):
	if not initial: minimized = !minimized
	vbox.visible = !minimized
	if minimized:
		panel.size = header.size + Vector2(10,0)
		button.text = "+"
	else:
		panel.size = expanded_size
		button.text = "-"

func handle_value_bool_change(index: int, value: ValueBehavior, optionButton : OptionButton):
	optionButton.select(index)
	value.bool_value = optionButton.get_item_text(index)
	
func handle_value_enum_change(index: int, value: ValueBehavior, optionButton: OptionButton):
	optionButton.select(index)
	value.enum_value = value.enum_choices[index]
	
func handle_update_value_float_change(new_value: float, value: ValueBehavior, label_current: Label, slider :HSlider):
	value.float_value = new_value
	slider.value = new_value
	label_current.text = str(new_value)
	
func _handle_slider_drag_start(hbox: HBoxContainer):
	hbox.visible = true
	
func _handle_slider_drag_end(value_changed: bool, hbox: HBoxContainer):
	hbox.visible = false

func _get_configuration_warnings():
	var message = []
	if not is_instance_of(self.get_parent(), PanelContainer):
		message.append("Prototyping UI needs to be the child of a PanelContainer.")
	if not _at_least_one_valid_child():
		message.append("Prototyping UI needs to have Value children if you want to display them.")	
	return message	

func _at_least_one_valid_child():
	for childNode in self.get_children():
		if is_instance_of(childNode, CodeBehavior) or is_instance_of(childNode, ValueBehavior):
			return true
	return false
	
