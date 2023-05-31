@tool
#thumb("CenterView")
extends Behavior
class_name PrototypingUI

var panel: PanelContainer
var muted_gray: Color = Color(0.69, 0.69, 0.69, 1)

# Called when the node enters the scene tree for the first time.
func _ready():
	super._ready()
	if not is_instance_of(self.get_parent(), PanelContainer):
		push_error("Prototyping UI needs to be the child of a PanelContainer.")
		return
	panel = self.get_parent()
	
	var scrollContainer = ScrollContainer.new()
	var vbox = VBoxContainer.new()
	vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	vbox.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
	
	for childNode in self.get_children():
		
		# making sure to only create sliders for value behaviours
		if not is_instance_of(childNode, Value):
			continue
		
		var name = childNode.name
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
		label_min.text = str(childNode.from)
		label_min.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		label_min.add_theme_color_override("font_color",muted_gray)
		
		# value max label
		var label_max = Label.new()
		label_max.text = str(childNode.to)
		label_max.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		label_max.add_theme_color_override("font_color",muted_gray)
		
		var current_vbox = VBoxContainer.new()
		current_vbox.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
		
		# current value label
		var label_current = Label.new()
		label_current.text = str(childNode.value)
		label_current.vertical_alignment = VERTICAL_ALIGNMENT_TOP
		current_vbox.add_child(label_current)

		lower_hbox.add_child(label_min)
		lower_hbox.add_spacer(false)
		lower_hbox.add_child(label_max)
		lower_hbox.visible = false
		
		# slider 
		var hslider = HSlider.new()
		hslider.min_value = childNode.from
		hslider.max_value = childNode.to
		hslider.step = childNode.step_size
		hslider.value = childNode.value
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
		vbox.add_child(hbox)
	scrollContainer.add_child(vbox)
	# adding through deferred call as it might fail otherwise
	panel.add_child.call_deferred(scrollContainer)
	# print("Prototype UI generated successfully")
	
	
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
	
