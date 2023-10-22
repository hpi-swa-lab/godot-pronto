@tool
#thumb("AnimationTrackList")
extends Behavior
class_name PerformanceUIBehavior

# This code is still unoptimized, feel free to improve it

signal fps_warning(current_fps: int)

# This enum was extracted from [code]Performance[/code] as we can not access
# the entire list programatically
enum monitor {
		TIME_FPS,
		TIME_PROCESS,
		TIME_PHYSICS_PROCESS,
		TIME_NAVIGATION_PROCESS,
		MEMORY_STATIC,
		MEMORY_STATIC_MAX,
		MEMORY_MESSAGE_BUFFER_MAX,
		OBJECT_COUNT,
		OBJECT_RESOURCE_COUNT,
		OBJECT_NODE_COUNT,
		OBJECT_ORPHAN_NODE_COUNT,
		RENDER_TOTAL_OBJECTS_IN_FRAME,
		RENDER_TOTAL_PRIMITIVES_IN_FRAME,
		RENDER_TOTAL_DRAW_CALLS_IN_FRAME,
		RENDER_VIDEO_MEM_USED,
		RENDER_TEXTURE_MEM_USED,
		RENDER_BUFFER_MEM_USED,
		PHYSICS_2D_ACTIVE_OBJECTS,
		PHYSICS_2D_COLLISION_PAIRS,
		PHYSICS_2D_ISLAND_COUNT,
		PHYSICS_3D_ACTIVE_OBJECTS,
		PHYSICS_3D_COLLISION_PAIRS,
		PHYSICS_3D_ISLAND_COUNT,
		AUDIO_OUTPUT_LATENCY,
		NAVIGATION_ACTIVE_MAPS,
		NAVIGATION_REGION_COUNT,
		NAVIGATION_AGENT_COUNT,
		NAVIGATION_LINK_COUNT,
		NAVIGATION_POLYGON_COUNT,
		NAVIGATION_EDGE_COUNT,
		NAVIGATION_EDGE_MERGE_COUNT,
		NAVIGATION_EDGE_CONNECTION_COUNT,
		NAVIGATION_EDGE_FREE_COUNT,
		MONITOR_MAX
	}

## Set the lower limit of when the fps_warning signal should be fired. (0 means never)
@export var fps_warn: int = 0:
	set(value):
		fps_warn = max(0,value)

@export_group("Metrics to display")
@export_subgroup("Defaults")
@export var TIME_FPS: bool = true
@export var OBJECT_NODE_COUNT: bool = true
@export_subgroup("Time")
@export var TIME_PROCESS: bool = false
@export var TIME_PHYSICS_PROCESS: bool = false
@export var TIME_NAVIGATION_PROCESS: bool = false
@export_subgroup("Memory")
@export var MEMORY_STATIC: bool = false
@export var MEMORY_STATIC_MAX: bool = false
@export var MEMORY_MESSAGE_BUFFER_MAX: bool = false
@export_subgroup("Object")
@export var OBJECT_COUNT: bool = false
@export var OBJECT_RESOURCE_COUNT: bool = false
@export var OBJECT_ORPHAN_NODE_COUNT: bool = false
@export_subgroup("Render")
@export var RENDER_TOTAL_OBJECTS_IN_FRAME: bool = false
@export var RENDER_TOTAL_PRIMITIVES_IN_FRAME: bool = false
@export var RENDER_TOTAL_DRAW_CALLS_IN_FRAME: bool = false
@export var RENDER_VIDEO_MEM_USED: bool = false
@export var RENDER_TEXTURE_MEM_USED: bool = false
@export var RENDER_BUFFER_MEM_USED: bool = false
@export_subgroup("Physics")
@export var PHYSICS_2D_ACTIVE_OBJECTS: bool = false
@export var PHYSICS_2D_COLLISION_PAIRS: bool = false
@export var PHYSICS_2D_ISLAND_COUNT: bool = false
@export var PHYSICS_3D_ACTIVE_OBJECTS: bool = false
@export var PHYSICS_3D_COLLISION_PAIRS: bool = false
@export var PHYSICS_3D_ISLAND_COUNT: bool = false
@export_subgroup("Audio")
@export var AUDIO_OUTPUT_LATENCY: bool = false
@export_subgroup("Navigation")
@export var NAVIGATION_ACTIVE_MAPS: bool = false
@export var NAVIGATION_REGION_COUNT: bool = false
@export var NAVIGATION_AGENT_COUNT: bool = false
@export var NAVIGATION_LINK_COUNT: bool = false
@export var NAVIGATION_POLYGON_COUNT: bool = false
@export var NAVIGATION_EDGE_COUNT: bool = false
@export var NAVIGATION_EDGE_MERGE_COUNT: bool = false
@export var NAVIGATION_EDGE_CONNECTION_COUNT: bool = false
@export var NAVIGATION_EDGE_FREE_COUNT: bool = false

## If [code]true[/code] the PerformanceUI starts minimized.
@export var minimized: bool = false

@export var panel_size: Vector2 = Vector2(300, 200):
	set(v):
		panel_size = v
		if panel:
			panel.size = panel_size
			_build_panel()
			queue_redraw()

# The label_cache serves as a dictionary to store all our exisitng labels at run time
var label_cache = {}

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
	if not get_tree(): return
	
	panel = PanelContainer.new()
	panel.size = panel_size
	
	self.add_child(panel)
	_build_panel()
	
func _process(delta):
	super._process(delta)
	if !Engine.is_editor_hint():
		var fps = Engine.get_frames_per_second()
		if fps_warn > 0 and fps <= fps_warn:
			fps_warning.emit(fps)
		for label_entry in label_cache:
			var value = Performance.get_monitor(label_cache[label_entry]["id"])
			label_cache[label_entry]["label"].text = _beautify_name(label_entry) + ": " + str(value)

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
	pass

func _build_panel():
	if not get_tree(): # This happens on godot startup
		return
	_clear_panel()
	vbox = VBoxContainer.new()
	header = HBoxContainer.new()
	var scrollContainer = ScrollContainer.new()
	
	vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	vbox.size_flags_vertical = Control.SIZE_EXPAND_FILL
	
	var counter = 0
	for current_monitor in monitor.keys():
		if self.get(current_monitor):
			var monitor_label = Label.new()
#			monitor_label.set("theme_override_font_sizes/font_size", font_size)
#			monitor_label.set("theme_override_colors/font_color", font_color)
			label_cache[monitor.keys()[counter]] = {"id": counter, "label": monitor_label}
			vbox.add_child(monitor_label)
		counter += 1
	
#	var nodes_to_add = []
#
#	if include_all_values:
#		nodes_to_add = _get_valid_children(get_tree().root)
#	else:
#		nodes_to_add = _get_valid_children(self)
#
#	var added_any_nodes = false
#	for childNode in nodes_to_add:
#		added_any_nodes = maybe_add_config(childNode) or added_any_nodes
#
#	if not added_any_nodes and not Engine.is_editor_hint(): # Hide the panel during the game if no Values are found
#		self.visible = false
#		return
#
	scrollContainer.add_child(vbox)
	scrollContainer.size_flags_vertical = Control.SIZE_EXPAND_FILL
	
	var outerVbox = VBoxContainer.new()
	outerVbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	outerVbox.size_flags_vertical = Control.SIZE_EXPAND_FILL
	header = create_header()
	outerVbox.add_child(header)
	outerVbox.add_child(scrollContainer)
	
	panel.add_child.call_deferred(outerVbox)
	
func _clear_panel():
	for child in panel.get_children():
		child.queue_free()
	
func _create_spacer():
	var spacer = VBoxContainer.new()
	spacer.custom_minimum_size = Vector2(10,0)
	return spacer

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
	var text = Label.new()
	text.text = self.name
	hbox.add_child(text)
	return hbox

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

func handles():
	return [
		Handles.SetPropHandle.new(panel_size,
			Utils.icon_from_theme("EditorHandle", self),
			self,
			"panel_size",
			func (coord): return floor(coord).clamp(Vector2(1, 1), Vector2(10000, 10000)))
	]

func _beautify_name(name: String):
	var output = ""
	for s in name.split("_"):
		var tmp = s.to_lower()
		tmp[0] = tmp[0].to_upper()
		output = output + " " + tmp
	return output
