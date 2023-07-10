## based and adapted from https://godotengine.org/asset-library/asset/374
@tool
extends VBoxContainer

signal update_request()
signal texture_selected(texture)

@onready var search_box

@onready var search_box_count_label
@onready var icons_control
@onready var previews_container
@onready var previews_scroll
@onready var icon_info

@onready var icon_preview_size_range
@onready var icon_info_label
@onready var icon_preview
@onready var icon_copied_label
@onready var icon_size_label
@onready var icon_preview_size

const SELECT_ICON_MSG = "Select any tile."
const ICON_SIZE_MSG = "Icon size: "
const NUMBER_ICONS_MSG = "Found: "

const MIN_ICON_SIZE = 16
const MAX_ICON_SIZE = 128

var icon_size = MIN_ICON_SIZE
var filter = ''

var _update_queued = false

var selected: TextureRect

var plugin


func _ready():
	search_box = get_node("body/search")
	search_box_count_label = search_box.get_node("found")
	icons_control = get_node("body/icons")
	previews_container = icons_control.get_node("previews/container")
	previews_scroll = icons_control.get_node("previews")
	icon_info = icons_control.get_node("info/icon")

	icon_preview_size_range = icon_info.get_node("params/size/range")
	icon_info_label = icon_info.get_node("label")
	icon_preview = icon_info.get_node("preview")
	icon_copied_label = icon_info.get_node("copied")
	icon_size_label = icon_info.get_node("size")
	icon_preview_size = icon_info.get_node("params/size/pixels")
	
	icon_info_label.text = SELECT_ICON_MSG
	icon_preview_size_range.min_value = MIN_ICON_SIZE
	icon_preview_size_range.max_value = MAX_ICON_SIZE
	icon_preview.custom_minimum_size = Vector2(MAX_ICON_SIZE, MAX_ICON_SIZE)

	_queue_update()


func _queue_update():
	if not is_inside_tree():
		return

	if _update_queued:
		return

	_update_queued = true

	call_deferred("_update_icons")


func add_icon(p_icon, p_name):
	var icon = TextureRect.new()
	icon.expand = true
	icon.texture = p_icon
	icon.custom_minimum_size = Vector2(icon_size, icon_size)
	icon.tooltip_text = p_name
	icon.name = p_name

	icon.gui_input.connect(Callable(_icon_gui_input).bind(icon))
	previews_container.add_child(icon)


func _icon_gui_input(event, icon):
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT:
			selected = icon
	elif event is InputEventMouseMotion:
		# Preview hovered icon on the side panel
		icon_info_label.text = icon.tooltip_text
		icon_preview.texture = icon.texture
		icon_size_label.text = ICON_SIZE_MSG + str(icon.texture.get_size())


func display():
	if previews_container.get_child_count() == 0:
		# First time, request to create previews by the plugin
		emit_signal("update_request")
		call_deferred('popup_centered_ratio', 0.5)

func clear():
	for idx in previews_container.get_child_count():
		previews_container.get_child(idx).queue_free()


func _on_size_changed(pixels):
	icon_size = int(clamp(pixels, MIN_ICON_SIZE, MAX_ICON_SIZE))
	_queue_update()


func _update_icons():
	var number = 0

	for idx in previews_container.get_child_count():
		var icon = previews_container.get_child(idx)

		if not filter.is_subsequence_ofn(icon.tooltip_text):
#		if not filter.is_subsequence_of(icon.tooltip_text):
			icon.visible = false
		else:
			icon.visible = true
			number += 1

		icon.custom_minimum_size = Vector2(icon_size, icon_size)
		icon.size = icon.custom_minimum_size

	var cols = int((size.x-$body/icons/info.size.x) / (icon_size + 5))
	previews_container.columns = cols - 1
	icon_preview_size.text = str(icon_size) + " px"

	search_box_count_label.text = NUMBER_ICONS_MSG + str(number)
	
	_update_queued = false

func _on_window_visibility_changed():
	if visible:
		_queue_update()


func _on_window_resized():
	_queue_update()


func _on_search_text_changed(text):
	filter = text
	_queue_update()


func _on_container_mouse_exited():
	icon_info_label.text = SELECT_ICON_MSG if selected == null else "Current Selection"
	icon_size_label.text = ''
	icon_copied_label.hide()
	icon_preview.texture = null if selected == null else selected.texture


func _on_window_about_to_show():
	# For some reason can't get proper rect size, so need to wait
	await previews_container.sort_children
#	yield(previews_container, 'sort_children')
	search_box.grab_focus()
	_queue_update()

func _on_button_pressed():
	if selected:
		texture_selected.emit(selected.texture)
