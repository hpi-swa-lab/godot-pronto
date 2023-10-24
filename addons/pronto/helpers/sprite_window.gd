## based on https://godotengine.org/asset-library/asset/374
@tool
extends VBoxContainer

signal texture_selected(texture)

@onready var search_box

@onready var search_box_count_label

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
	icon.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	
	var s = G.at("_pronto_editor_plugin").get_editor_interface().get_editor_settings()
	icon.self_modulate = s.get("interface/theme/base_color").inverted()
	
	icon.gui_input.connect(Callable(_icon_gui_input).bind(icon))
	%container.add_child(icon)


func _icon_gui_input(event, icon):
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT:
			selected = icon
			texture_selected.emit(selected.texture)

func clear():
	for idx in %container.get_child_count():
		%container.get_child(idx).queue_free()

func _update_icons():
	var number = 0

	for idx in %container.get_child_count():
		var icon = %container.get_child(idx)

		if not filter.is_subsequence_ofn(icon.tooltip_text):
#		if not filter.is_subsequence_of(icon.tooltip_text):
			icon.visible = false
		else:
			icon.visible = true
			number += 1

		icon.custom_minimum_size = Vector2(icon_size, icon_size)
		icon.size = icon.custom_minimum_size

	var cols = int(size.x / (icon_size + 5))
	%container.columns = cols

	search_box_count_label.text = "Found: " + str(number)
	
	_update_queued = false

func _on_window_visibility_changed():
	if visible:
		_queue_update()


func _on_window_resized():
	_queue_update()


func _on_search_text_changed(text):
	filter = text
	_queue_update()

func _on_window_about_to_show():
	# For some reason can't get proper rect size, so need to wait
	await %container.sort_children
#	yield(previews_container, 'sort_children')
	search_box.grab_focus()
	_queue_update()
