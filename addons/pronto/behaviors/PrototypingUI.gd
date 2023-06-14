@tool
#thumb("CenterView")
extends Behavior
class_name PrototypingUI

var panel: PanelContainer
var muted_gray: Color = Color(0.69, 0.69, 0.69, 1)

# Called when the node enters the scene tree for the first time.
func _ready():
	super._ready()
	#if not is_instance_of(self.get_parent(), PanelContainer):
	#	push_error("Prototyping UI needs to be the child of a PanelContainer.")
	#	return
	panel = self.get_parent()
	
	var scrollContainer = ScrollContainer.new()
	var vbox = VBoxContainer.new()
	vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	vbox.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
	
	for childNode in self.get_children():
		
		# making sure to only create sliders for value behaviours
		if is_instance_of(childNode, Value):
			vbox.add_child(create_ui_slider_for_values(childNode))
		elif is_instance_of(childNode, Code):
			vbox.add_child(create_ui_for_code(childNode))
		elif is_instance_of(childNode,AdvancedValue):
			vbox.add_child(create_ui_for_advanced_value(childNode))
		scrollContainer.add_child(vbox)
	# adding through deferred call as it might fail otherwise
	panel.add_child.call_deferred(scrollContainer)
	# print("Prototype UI generated successfully")
	
	
func create_ui_for_advanced_value(advanced_value: AdvancedValue):
	if advanced_value.selectType == "Float":
		return create_ui_slider_for_advanced_value_float(advanced_value)
	elif advanced_value.selectType == "Enum":
		return create_ui_for_advanced_value_enum(advanced_value)
	elif advanced_value.selectType == "Bool":
		return create_ui_for_advanced_value_bool(advanced_value)
	return
	
	
	
func create_ui_for_advanced_value_enum(value: AdvancedValue):
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
	#hslider.value_changed.connect(handle_slider_update_advanced_value_float_change.bind(value))
	optionButton.item_selected.connect(handle_advanced_value_enum_change.bind(value))
	hbox.add_child(label)
	hbox.add_child(optionButton)
	
	return hbox
	
func create_ui_for_advanced_value_bool(value: AdvancedValue):
	var name = value.name
	var label = Label.new()
	label.text = name + ":"
	label.vertical_alignment = VERTICAL_ALIGNMENT_TOP
	
	var hbox = HBoxContainer.new()
	var optionButton = OptionButton.new()
	optionButton.focus_mode = 0
	
	
	optionButton.add_item("True", 1)
	optionButton.add_item("False", 0)
	#hslider.value_changed.connect(handle_slider_update_advanced_value_float_change.bind(value))
	optionButton.item_selected.connect(handle_advanced_value_bool_change.bind(value))
	hbox.add_child(label)
	hbox.add_child(optionButton)
	return hbox
	
func create_ui_for_code(code: Code):
	var button = Button.new()
	var name = code.name
	var args = code.arguments
	var function = code.execute(args)
	button.text = code.name
	#button.pressed.connect(function)
	return(button)
	
	
func create_ui_slider_for_advanced_value_float(value: AdvancedValue):
	var name = value.name
	print("Adding slider for " + name)
	
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
	hslider.value = value.float_value
	# setting growth flags so that the slider resized to parent container
	hslider.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hslider.size_flags_vertical = Control.SIZE_SHRINK_CENTER

	# setting focus mode to ignore keyboard input
	hslider.focus_mode = Slider.FOCUS_NONE
	# signal | this potentially fires very often during dragging of the slider
	hslider.value_changed.connect(handle_slider_update_advanced_value_float_change.bind(value))
	# fancy ui signals
	hslider.drag_started.connect(_handle_slider_drag_start.bind(lower_hbox))
	hslider.drag_ended.connect(_handle_slider_drag_end.bind(lower_hbox))
	
	middle_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	middle_vbox.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
	middle_vbox.add_child(hslider)
	middle_vbox.add_child(lower_hbox)
	
	# adding to node tree
	hbox.add_child(name_vbox)
	hbox.add_child(middle_vbox)
	hbox.add_child(current_vbox)
	return hbox


#TODO: Remove if Advanced Value replaces Value
func create_ui_slider_for_values(value: Value):
	var name = value.name
	print("Adding slider for " + name)
	
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
	label_min.text = str(value.from)
	label_min.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label_min.add_theme_color_override("font_color",muted_gray)
	
	# value max label
	var label_max = Label.new()
	label_max.text = str(value.to)
	label_max.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label_max.add_theme_color_override("font_color",muted_gray)
	
	var current_vbox = VBoxContainer.new()
	current_vbox.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
	
	# current value label
	var label_current = Label.new()
	label_current.text = str(value.value)
	label_current.vertical_alignment = VERTICAL_ALIGNMENT_TOP
	current_vbox.add_child(label_current)

	lower_hbox.add_child(label_min)
	lower_hbox.add_spacer(false)
	lower_hbox.add_child(label_max)
	lower_hbox.visible = false
	
	# slider 
	var hslider = HSlider.new()
	hslider.min_value = value.from
	hslider.max_value = value.to
	hslider.step = value.step_size
	hslider.value = value.value
	# setting growth flags so that the slider resized to parent container
	hslider.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hslider.size_flags_vertical = Control.SIZE_SHRINK_CENTER

	# setting focus mode to ignore keyboard input
	hslider.focus_mode = Slider.FOCUS_NONE
	# signal | this potentially fires very often during dragging of the slider
	hslider.value_changed.connect(handle_slider_update.bind(name, label_current))
	# fancy ui signals
	hslider.drag_started.connect(_handle_slider_drag_start.bind(lower_hbox))
	hslider.drag_ended.connect(_handle_slider_drag_end.bind(lower_hbox))
	
	middle_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	middle_vbox.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
	middle_vbox.add_child(hslider)
	middle_vbox.add_child(lower_hbox)
	
	# adding to node tree
	hbox.add_child(name_vbox)
	hbox.add_child(middle_vbox)
	hbox.add_child(current_vbox)
	return hbox
	
	
	
func handle_advanced_value_bool_change(index: int, value: AdvancedValue):
	value.bool_value = index == 1
	
func handle_advanced_value_enum_change(index: int, value: AdvancedValue):
	value.enum_value = value.enum_choices[index]
	
func handle_slider_update_advanced_value_float_change(new_value: float, value: AdvancedValue):
	value.float_value = new_value
	
func handle_slider_update(value: float, varRef: String, label_current: Label):
	label_current.text = str(value)
	G.put(varRef, value)
	
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
		if is_instance_of(childNode, Value):
			return true
	return false
	
func _process(delta):
	super._process(delta)
