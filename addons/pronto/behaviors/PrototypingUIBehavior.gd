@tool
#thumb("Grid")
extends Behavior
class_name PrototypingUIBehavior

## Add to your scene to edit properties while in-game.
## If you have any ValueBehaviors within your game and do not add a PrototypingUI,
## one will automatically be created with these default values

## If true, the PrototypingUI will be visible in the export
@export var show_in_export = true

## If [code]true[/code], all values in the scene are added to the menu (if they are visible) [br]
## If [code]false[/code], only children ValueBehaviors are added to the menu (if they are visible)
@export var include_all_values = true

## If [code]true[/code] the PrototypingUI starts minimized.
@export var minimized: bool = false

@export var panel_size: Vector2 = Vector2(300, 200):
	set(v):
		panel_size = v
		if panel:
			panel.size = panel_size
			_build_panel()
			queue_redraw()

var panel: PanelContainer
var muted_gray: Color = Color(0.69, 0.69, 0.69, 1)
var vbox: VBoxContainer = VBoxContainer.new()
var header: HBoxContainer = HBoxContainer.new()

# Variables for moving and resizing UI container.
var start: Vector2
var init_position: Vector2
var is_moving: bool
var is_resizing: bool
var resize_x: bool
var resize_y: bool
var initial_size: Vector2

var grab_threshold:= 30
var resize_threshold:= 10

# Called when the node enters the scene tree for the first time.
func _ready():
	super._ready()
	if OS.has_feature("release") and not show_in_export: return
	if not get_tree(): return
	
	panel = PanelContainer.new()
	panel.size = panel_size
	call_deferred("_reparent_and_build")

func _reparent_and_build():
	# If the parent is not a CanvasLayer, create one and reparent the UI to it. Only do this in-game so it can be moved around in the editor.
	if (!get_parent() is CanvasLayer and not Engine.is_editor_hint()):
		var canvasLayer = CanvasLayer.new()
		var offset = global_position - get_parent().global_position
		get_parent().add_child(canvasLayer)
		reparent(canvasLayer)
	self.add_child(panel)
	_build_panel()

func _draw():
	super._draw()
	draw_rect(Rect2(Vector2(0, 0), Vector2(panel_size.x, 30)), Color.BLACK, true)

func _input(event):
	if Input.is_action_just_pressed("input_left_mouse") and event is InputEventMouse:
		var rect = panel.get_global_rect()
		var localMousePos = event.position - get_global_position()
		if localMousePos.y > 0 and localMousePos.y < grab_threshold:
			if localMousePos.x > 0 and localMousePos.x < rect.size.x:
				start = event.position
				init_position = get_global_position()
				is_moving = true
		else:
			if localMousePos.y > 0 and localMousePos.y < rect.size.y:
				if abs(localMousePos.x - rect.size.x) < resize_threshold:
					start.x = event.position.x
					initial_size.x = panel_size.x
					resize_x = true
					is_resizing = true
				
				if localMousePos.x < resize_threshold &&  localMousePos.x > -resize_threshold:
					start.x = event.position.x
					init_position.x = get_global_position().x
					initial_size.x = panel_size.x
					is_resizing = true
					resize_x = true
			
			if localMousePos.x > 0 and localMousePos.x < rect.size.x:
				if abs(localMousePos.y - rect.size.y) < resize_threshold:
					start.y = event.position.y
					initial_size.y = panel_size.y
					resize_y = true
					is_resizing = true
				
				if localMousePos.y < resize_threshold &&  localMousePos.y > -resize_threshold:
					start.y = event.position.y
					init_position.y = get_global_position().y
					initial_size.y = panel_size.y
					is_resizing = true
					resize_y = true

	if Input.is_action_pressed("input_left_mouse"):
		if is_moving:
			set_position(init_position + (event.position - start))

		if is_resizing:
			var newWidith = panel_size.x
			var newHeight = panel_size.y

			if resize_x:
				newWidith = initial_size.x - (start.x - event.position.x)
			if resize_y:
				newHeight = initial_size.y - (start.y - event.position.y)

			if init_position.x != 0:
				newWidith = initial_size.x + (start.x - event.position.x)
				set_position(Vector2(init_position.x - (newWidith - initial_size.x), get_position().y))

			if init_position.y != 0:
				newHeight = initial_size.y + (start.y - event.position.y)
				set_position(Vector2(get_position().x, init_position.y - (newHeight - initial_size.y)))

			var min_x = panel.get_minimum_size().x
			var min_y = panel.get_minimum_size().y
			panel_size = Vector2(max(newWidith, min_x), max(newHeight, min_y))

	if Input.is_action_just_released("input_left_mouse"):
		is_moving = false
		init_position = Vector2(0,0)
		resize_x = false
		resize_y = false
		is_resizing = false

func _build_panel():
	if not get_tree(): # This happens on godot startup
		return
	_clear_panel()
	vbox = VBoxContainer.new()
	header = HBoxContainer.new()
	var scrollContainer = ScrollContainer.new()
	
	vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	vbox.size_flags_vertical = Control.SIZE_EXPAND_FILL
	
	var nodes_to_add = []
	
	if include_all_values:
		nodes_to_add = _get_valid_children(get_tree().root)
	else:
		nodes_to_add = _get_valid_children(self)
	
	var added_any_nodes = false
	for childNode in nodes_to_add:
		added_any_nodes = maybe_add_config(childNode) or added_any_nodes

	if not added_any_nodes and not Engine.is_editor_hint(): # Hide the panel during the game if no Values are found
		self.visible = false
		return
	
	scrollContainer.add_child(vbox)
	scrollContainer.size_flags_vertical = Control.SIZE_EXPAND_FILL
	
	var outerVbox = VBoxContainer.new()
	outerVbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	outerVbox.size_flags_vertical = Control.SIZE_EXPAND_FILL
	header = create_header()
	outerVbox.add_child(header)
	outerVbox.add_child(scrollContainer)
	
	panel.add_child.call_deferred(outerVbox)
	
func _create_spacer():
	var spacer = VBoxContainer.new()
	spacer.custom_minimum_size = Vector2(10,0)
	return spacer

func _tree_changed(node):
	if not self.is_inside_tree(): return
	if _node_is_valid(node):
		_build_panel()

func _clear_panel():
	for child in panel.get_children():
		child.queue_free()

func maybe_add_config(node: Node):
	if _proccessed_duplicate_node(node): 
		return false
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

func _get_valid_children(node):
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
	
	hbox.add_child(_create_spacer())
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

	if(value.bool_value == "TRUE"):
		optionButton.select(1)
	else:
		optionButton.select(0)
	
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
	
	hbox.add_child(_create_spacer())
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
	
	var container = VBoxContainer.new()
	container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	container.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
	
	var hbox = HBoxContainer.new()
	var middle_vbox = VBoxContainer.new()
	var edit_hbox = HBoxContainer.new()
	var lower_hbox = HBoxContainer.new()
	var name_hbox = HBoxContainer.new()
	name_hbox.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
	
	# value name label
	var label = Label.new()
	label.text = name + ":"
	label.vertical_alignment = VERTICAL_ALIGNMENT_TOP
	name_hbox.add_child(label)
	
	# value min label
	var label_min = Label.new()
	label_min.text = str(value.float_min)
	label_min.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label_min.add_theme_color_override("font_color",muted_gray)
	
	# value max label
	var label_max = Label.new()
	label_max.text = str(value.float_max)
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
	hslider.min_value = value.float_min
	hslider.max_value = value.float_max
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
	
	var edit_button = Button.new()
	edit_button.focus_mode = 0
	edit_button.text = "✎"
	edit_button.pressed.connect(_toggle_edit_view.bind(edit_hbox))
	
	middle_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	middle_vbox.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
	middle_vbox.add_child(hslider)
	middle_vbox.add_child(lower_hbox)

	# adding to node tree
	hbox.add_child(_create_spacer())
	hbox.add_child(name_hbox)
	hbox.add_child(middle_vbox)
	hbox.add_child(current_vbox)
	hbox.add_child(edit_button)
	hbox.add_child(reset_button)
	hbox.add_child(_create_spacer())
	
	_build_edit_menu(edit_hbox, value, hslider, label_min, label_max)
	
	container.add_child(hbox)
	container.add_child(edit_hbox)
	return container
	
func _proccessed_duplicate_node(node):
	var name = node.name
	for entry in vbox.get_children():
		var value_label
		# layout is different based on value type
		# vbox = float ValueBehavior
		if is_instance_of(entry, VBoxContainer):
			value_label = entry.get_child(0).get_child(1).get_child(0)
			if name == value_label.text.substr(0,value_label.text.length()-1):
				_update_duplicate_counter(entry)
				return true
		# hbox = bool/enum ValueBehavior
		if is_instance_of(entry, HBoxContainer):
			value_label = entry.get_child(1)
			if name == value_label.text.substr(0,value_label.text.length()-1):
				_update_duplicate_counter(entry)
				return true
		if is_instance_of(entry, Button):
			value_label = entry
			if name == value_label.text:
				return true
	return false

func _update_duplicate_counter(entry):
	if is_instance_of(entry, VBoxContainer):
		# check if it already has a duplicate-counter label
		if entry.get_child(0).get_child(1).get_child_count() == 1:
			var counter_label = _prepare_counter_label()
			entry.get_child(0).get_child(1).add_child(counter_label)
		else:	
			var counter_label = entry.get_child(0).get_child(1).get_child(1)
			counter_label.text = "+" + str(int(counter_label.text.substr(1,counter_label.text.length())) + 1)
	if is_instance_of(entry, HBoxContainer):
		# check if it already has a duplicate-counter label
		if not is_instance_of(entry.get_child(2), Label):
			var counter_label = _prepare_counter_label()
			entry.add_child(counter_label)
			entry.move_child(counter_label, 2)
		else:
			var counter_label = entry.get_child(2)
			counter_label.text = "+" + str(int(counter_label.text.substr(1,counter_label.text.length())) + 1)
	if is_instance_of(entry, CodeEdit):
		# todo: figure out if we want to do anything for multiple CodeEdits
		pass
			
func _prepare_counter_label():
	var counter_label = Label.new()
	counter_label.vertical_alignment = VERTICAL_ALIGNMENT_TOP
	counter_label.size_flags_vertical = Control.SIZE_FILL
	counter_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	counter_label.text = "+1"
	# tooltip doesn't get displayed, feel free to fix
	counter_label.tooltip_text = "This value exists multiple times in the scene"
	
	var label_settings = LabelSettings.new()
	label_settings.font_size = 8
	counter_label.label_settings = label_settings
	return counter_label
			
func _build_edit_menu(edit_hbox: HBoxContainer, value: ValueBehavior, \
	slider: HSlider, label_min: Label, label_max: Label):
	## Value vbox
	var value_box = VBoxContainer.new()
	value_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	value_box.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
	
	var value_label = Label.new()
	value_label.text = "Value:"
	value_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	value_label.add_theme_color_override("font_color",muted_gray)
	
	var value_input = SpinBox.new()
	value_input.step = value.float_step_size
	value_input.allow_greater = true
	value_input.allow_lesser = true
	value_input.value = value.float_value
	value_input.value_changed.connect(_value_changed.bind(value, slider))
	value_input.changed.connect(_value_changed_other.bind(value, value_input, slider))
	
	slider.value_changed.connect(_slider_changed.bind(value_input))
	
	value_box.add_child(value_label)
	value_box.add_child(value_input)
	
	## From vbox
	var from_box = VBoxContainer.new()
	from_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	from_box.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
	
	var from_label = Label.new()
	from_label.text = "From:"
	from_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	from_label.add_theme_color_override("font_color",muted_gray)
	
	var from_input = SpinBox.new()
	from_input.allow_greater = true
	from_input.allow_lesser = true
	from_input.step = value.float_step_size
	from_input.value = value.float_min
	from_input.value_changed.connect(_from_changed.bind(value, value_input, slider, label_min))
	
	from_box.add_child(from_label)
	from_box.add_child(from_input)
	
	## To vbox
	var to_box = VBoxContainer.new()
	to_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	to_box.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
	
	var to_label = Label.new()
	to_label.text = "To:"
	to_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	to_label.add_theme_color_override("font_color",muted_gray)
	
	var to_input = SpinBox.new()
	to_input.allow_greater = true
	to_input.allow_lesser = true
	to_input.step = value.float_step_size
	to_input.value = value.float_max
	to_input.value_changed.connect(_to_changed.bind(value, value_input, slider, label_max))
	
	to_box.add_child(to_label)
	to_box.add_child(to_input)
	
	## Step vbox
	var step_box = VBoxContainer.new()
	step_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	step_box.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
	
	var step_label = Label.new()
	step_label.text = "Step:"
	step_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	step_label.add_theme_color_override("font_color",muted_gray)
	
	var step_input = SpinBox.new()
	step_input.step = 0.00000001
	step_input.value = value.float_step_size
	step_input.value_changed.connect(_step_changed.bind(value, value_input, from_input, to_input, slider))
	
	step_box.add_child(step_label)
	step_box.add_child(step_input)
	
	edit_hbox.add_child(_create_spacer())
	edit_hbox.add_child(value_box)
	edit_hbox.add_child(step_box)
	edit_hbox.add_child(from_box)
	edit_hbox.add_child(to_box)
	edit_hbox.add_child(_create_spacer())
	
	edit_hbox.visible = false
	
func _slider_changed(new_value, value_input):
	value_input.value = new_value
	
func _step_changed(new_value: float, value: ValueBehavior, value_input: SpinBox, from_input: SpinBox,
	to_input: SpinBox, slider: HSlider):
	value.float_step_size = new_value
	value_input.step = new_value
	from_input.step = new_value
	to_input.step = new_value
	slider.step = new_value
	
func _from_changed(new_value: float, value: ValueBehavior, \
	value_input: SpinBox, slider: HSlider, label: Label):
	value.float_min = new_value
	value_input.min_value = new_value
	slider.min_value = new_value
	label.text = str(new_value)

func _to_changed(new_value: float, value: ValueBehavior, \
	value_input: SpinBox, slider: HSlider, label: Label):
	value.float_max = new_value
	value_input.max_value = new_value
	slider.max_value = new_value
	label.text = str(new_value)
	
func _value_changed(new_value: float, value: ValueBehavior, slider: HSlider):
	value.float_value = new_value
	slider.min_value = value.float_min
	slider.max_value = value.float_max
	slider.value = new_value
	
func _value_changed_other(value: ValueBehavior, value_input: SpinBox, slider: HSlider):
	_value_changed(value_input.value, value, slider)

func _toggle_edit_view(container: HBoxContainer):
	container.visible = not container.visible

func create_minimizing_button():
	var button = Button.new()
	button.text = "−"
	button.pressed.connect(handle_size_button_click.bind(button))
	if minimized:
		handle_size_button_click(button, true)
	return button
	
func create_header():
	var hbox = HBoxContainer.new()
	hbox.add_child(create_minimizing_button())
	hbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	# Add the title of the PUI
	var text = Label.new()
	text.text = self.name
	hbox.add_child(text)

	# Quick and dirty solution for restart button
	var restart_button = Button.new()
	restart_button.text = "⟳"
	restart_button.focus_mode = 0
	restart_button.alignment = HORIZONTAL_ALIGNMENT_RIGHT
	restart_button.tooltip_text = "Restart the game"
	restart_button.connect("pressed", func(): get_tree().reload_current_scene())
	hbox.add_child(restart_button)

	return hbox

func _sync_editor_value(value: ValueBehavior):
	var data = [value.name, value.selectType]
	match value.selectType:
		"Float":
			data.append(value.float_step_size)
			data.append(value.float_min)
			data.append(value.float_max)
			data.append(value.float_value)
		"Enum":
			data.append(value.enum_value)
		"Bool":
			data.append(value.bool_value)
	if EngineDebugger.is_active():
		EngineDebugger.send_message("pronto:value_set", data)

func handle_size_button_click(button: Button, initial: bool = false):
	if not initial: minimized = !minimized
	button.release_focus()
	vbox.visible = !minimized
	if minimized:
		panel.size = header.size
		button.text = "+"
	else:
		panel.size = panel_size
		button.text = "-"

func handle_value_bool_change(index: int, value: ValueBehavior, optionButton : OptionButton):
	optionButton.select(index)
	value.bool_value = optionButton.get_item_text(index)
	_sync_editor_value(value)
	
func handle_value_enum_change(index: int, value: ValueBehavior, optionButton: OptionButton):
	optionButton.select(index)
	value.enum_value = value.enum_choices[index]
	_sync_editor_value(value)
	
func handle_update_value_float_change(new_value: float, value: ValueBehavior, label_current: Label, slider :HSlider):
	value.float_value = new_value
	slider.value = new_value
	label_current.text = str(new_value)
	_sync_editor_value(value)
	pass

func _handle_slider_drag_start(hbox: HBoxContainer):
	hbox.visible = true
	
func _handle_slider_drag_end(value_changed: bool, hbox: HBoxContainer):
	hbox.visible = false

func handles():
	return [
		Handles.SetPropHandle.new(panel_size,
			Utils.icon_from_theme("EditorHandle", self),
			self,
			"panel_size",
			func (coord): return floor(coord).clamp(Vector2(1, 1), Vector2(10000, 10000)))
	]


