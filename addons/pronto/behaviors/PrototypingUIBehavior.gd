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

## Pressing this button applies all value changes made during the last runtime.
@export var runtime_values: int

var panel: PanelContainer
var muted_gray: Color = Color(0.69, 0.69, 0.69, 1)
var vbox: VBoxContainer = VBoxContainer.new()
var header: HBoxContainer = HBoxContainer.new()
var expanded_size = Vector2(0,0)

# Called when the node enters the scene tree for the first time.
func _ready():
	super._ready()
	if OS.has_feature("release") and not show_in_export: return
	if not get_tree(): return
	
	panel = PanelContainer.new()
	panel.size = panel_size
	expanded_size = panel.size
	
	self.add_child(panel)
	_build_panel()
	
	# Automatically rebuild the panel when nodes have changed
#	if Engine.is_editor_hint():
#		var tree = get_tree()
#		tree.node_added.connect(_tree_changed)
#		tree.node_removed.connect(_tree_changed)
#		tree.node_renamed.connect(_tree_changed)
#		tree.node_configuration_warning_changed.connect(_tree_changed)

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

func _tree_changed(node):
	if not self.is_inside_tree(): return
	if _node_is_valid(node):
		_build_panel()

func _clear_panel():
	for child in panel.get_children():
		child.queue_free()

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
	hbox.add_child(create_minimizing_button())
	hbox.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
	var text = Label.new()
	text.text = self.name
	hbox.add_child(text)
	return hbox

func _serialize_values():
	var value_nodes = _get_valid_children(get_tree().root)
	for value_obj in value_nodes:
		if not value_obj is ValueBehavior:
			continue
		var dir_path = "res://addons/pronto/value_resources"
		if not DirAccess.dir_exists_absolute(dir_path):
			DirAccess.make_dir_absolute(dir_path)
		var path = dir_path + "/" + value_obj.name + ".res"
		var file = FileAccess.open(path,
			FileAccess.WRITE)
		if file:
			var r = ValueResource.new()
			r._set_from_value(value_obj)
			ResourceSaver.save(r, path)
			file.close()

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
	_serialize_values()
	
func handle_value_enum_change(index: int, value: ValueBehavior, optionButton: OptionButton):
	optionButton.select(index)
	value.enum_value = value.enum_choices[index]
	_serialize_values()
	
func handle_update_value_float_change(new_value: float, value: ValueBehavior, label_current: Label, slider :HSlider):
	value.float_value = new_value
	slider.value = new_value
	label_current.text = str(new_value)
	_serialize_values()
	
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
