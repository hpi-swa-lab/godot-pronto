@tool
#thumb("Search")
extends Behavior
class_name Inspect

var default_property = 'position'
var default_expression = 'return self.%s' % default_property

const COOLDOWN_LENGTH_MS = 100

class Item:
	var label
	var value
	var cooldown_time := 0
	var property : String
	var expression
	var value_string : String
	
	func update(target: Node, index: int, inspect: Inspect) -> bool:
		var new_value
		if expression:
			label = "<expr%s>" % index
			if Engine.is_editor_hint():
				# FIXME: eval() does not work in editor mode
				new_value = null
			else:
				var result := ConnectionsList.eval_or_error(expression, ['target'], [target], inspect)
				new_value = "<error>" if result.error else result.value
		elif property:
			label = property
			new_value = target.get(property)
		
		if typeof(new_value) == typeof(value) and new_value == value:
			return false
		
		cooldown_time = Time.get_ticks_msec() + COOLDOWN_LENGTH_MS
		value = new_value
		value_string = str(new_value)
		return true
	
	func add_to_label(label: RichTextLabel, highlight_color: Color, should_truncate: bool = false):
		var full_string := get_display_string(should_truncate) + "\n"

		if Time.get_ticks_msec() >= cooldown_time:
			label.add_text(full_string)
			return
						
		label.push_color(highlight_color)	
		label.add_text(full_string)
		label.pop()
	
	func get_display_string(should_truncate := false) -> String:
		var string := value_string
		if should_truncate:
			string = Utils.ellipsize(string, 32)
		var full_string := "%s: %s" % [label, string]
		return full_string
		

func get_expression(i: int) -> String:
	if i >= len(items):
		return '<click to add>'
	return items[i].expression
func set_expression(i: int, v: String):
	if v == '<click to add>':
		# must not add placeholder
		return
	if i >= len(items):
		var new_item := Item.new()
		new_item.expression = v
		items.push_back(new_item)
	if v == '<remove>':
		items.remove_at(i)
	else:
		if v != null:
			items[i].property = "<statement(s)>"
		items[i].expression = v
	notify_property_list_changed()
	update()

func get_property(i: int) -> String:
	if i >= len(items):
		return '<click to add>'
	return items[i].property
func set_property(i: int, v: String):
	if v != null and v.begins_with('--'):
		# must not select group headers
		return
	if v == '<click to add>':
		# must not add placeholder
		return
	if i >= len(items):
		var new_item := Item.new()
		items.push_back(new_item)
	if v == '<remove>':
		items.remove_at(i)
	else:
		if v == '<statement(s)>':
			var property = items[i].property
			return set_expression(i, 'return target.%s' % (property if property else default_property))
		if v != null:
			items[i].expression = null
		items[i].property = v
	notify_property_list_changed()
	update()

var target: Node2D:
	get:
		return self.get_parent()

var background_color = Color(0, 0, 0, .2):
	set(v):
		background_color = v
		queue_redraw()

var color = Color.WHITE:
	set(v):
		label.set("theme_override_colors/default_color", v)
	get:
		return label.get("theme_override_colors/default_color")

var highlight_color := Color.RED

var shape_rect
var shape_size:
	set(v):
		shape_size = v
		shape_rect = Rect2(shape_size / -2, shape_size)
		if label != null:
			var string_rect = self.shape_rect.grow(-(padding + shadow_thickness))
			label.position = string_rect.position
			label.size = string_rect.size
		queue_redraw()

var label: RichTextLabel

var padding = 1
var shadow_thickness = 1

func _get(property):
	if property.match('property_?*'):
		var index = property.trim_prefix('property_').to_int()
		return get_property(index)
	if property.match('expression_?*'):
		var index = property.trim_prefix('expression_').to_int()
		return get_expression(index)

func _set(property, v):
	if property.match('property_?*'):
		var index = property.trim_prefix('property_').to_int()
		return set_property(index, v)
	if property.match('expression_?*'):
		var index = property.trim_prefix('expression_').to_int()
		return set_expression(index, v)

func _get_property_list():
	var property_list = []
	
	if target:
		var property_names = []
		property_names.push_front('<statement(s)>')
		for _class in Utils.all_classes_of(target):
			var new_property_names = ClassDB.class_get_property_list(_class, true)\
				.map(func(_property): return _property.name)
			if not len(new_property_names): continue
			
			property_names.push_back("-- %s --" % _class)
			new_property_names.sort()
			for name in new_property_names:
				if name[0] == name[0].to_upper():
					# not a useful property
					continue
				property_names.push_back(name)
		
		for i in len(items) + len(['<template>']):
			var _property_names = property_names.duplicate()
			# Do not remove the first item or the template item.
			if len(items) > 1 and i < len(items):
				_property_names.push_front('<remove>')
			
			var property = get_property(i)
			property_list.append({
				'name': 'property_%s' % i,
				'type': TYPE_STRING,
				'usage': PROPERTY_USAGE_DEFAULT,
				'hint': PROPERTY_HINT_ENUM,
				'hint_string': ','.join(_property_names)
			})
			if property == '<statement(s)>':
				# FIXME: Cannot edit expression at runtime because temporary syntax errors break everything - how to defer parsing?
				property_list.append({
					'name': 'expression_%s' % i,
					'type': TYPE_STRING,
					'usage': PROPERTY_USAGE_DEFAULT,
					'hint': PROPERTY_HINT_EXPRESSION
				})
	
	# export static properties
	# NOTE: we could also use export keyword for that, but this would add these
	# properties prior to the other group
	property_list.append({
		'name': "Appearance",
		'type': TYPE_NIL,
		'usage': PROPERTY_USAGE_CATEGORY
	})
	property_list.append({
		'name': 'background_color',
		'type': TYPE_COLOR,
		'usage': PROPERTY_USAGE_DEFAULT
	})
	property_list.append({
		'name': 'color',
		'type': TYPE_COLOR,
		'usage': PROPERTY_USAGE_DEFAULT
	})
	property_list.append({
		'name': 'highlight_color',
		'type': TYPE_COLOR,
		'usage': PROPERTY_USAGE_DEFAULT
	})
	property_list.append({
		'name': 'shape_size',
		'type': TYPE_VECTOR2,
		'usage': PROPERTY_USAGE_DEFAULT
	})
	
	return property_list

var items : Array[Item]

func _init():
	super._init()
	
	self.shape_size = Vector2(100, 100)
	self.set_property(0, default_property)
	
	label = RichTextLabel.new()
	label.set("theme_override_font_sizes/normal_font_size", 10)
	label.set("theme_override_constants/line_separation", -4)
	label.autowrap_mode = TextServer.AUTOWRAP_OFF
	label.mouse_filter = Control.MOUSE_FILTER_PASS
	self.shape_size = shape_size
	add_child(label)

func _ready():
	if Engine.is_editor_hint():
		# construction convenience: position ourselves below the parent's known bounds
		var parent = get_parent()
		var parent_rect = Utils.global_rect_of(parent)
		var parent_child_rect = parent.get_children() \
			.filter(func(child): return child != self) \
			.map(func(child): return Utils.global_rect_of(child)) \
			.reduce(func(a, b): return a.merge(b), parent_rect)
		self.position = Vector2(0,
			(parent_child_rect.end.y - parent_rect.end.y
				+ parent_rect.size.y + shape_size.y) / 2)
	
	super._ready()

func _process(delta):
	super._process(delta)
	
	self.update()

func update():
	if label == null:
		return
	
	if self.target == null:
		return
	
	for i in len(items):
		var item := items[i]
		item.update(self.target, i, self)
	
	var labels = ['<no target>'] if items == null else items.map(func(item: Item): return item.get_display_string(false))
	label.tooltip_text = "\n".join(labels)
	
	label.clear()
	for i in len(items):
		var item := items[i]
		item.add_to_label(label, highlight_color, i < len(items) - 1)
	label.text = label.text.rstrip("\n")


func _truncate_items(items: Array) -> Array:
	var truncated := []
	for pair in items:
		var short_value := Utils.ellipsize(pair[1], 32) as String
		truncated.push_back([pair[0],short_value])
	return truncated

func handles():
	return [
		Handles.SetPropHandle.new(shape_size / 2,
			Utils.icon_from_theme("EditorHandle", self),
			self,
			"shape_size",
			func (coord): return floor(coord * 2).clamp(Vector2(1, 1), Vector2(10000, 10000)))
	]

func _draw():
	super._draw()
	
	if shape_rect != null:
		draw_rect(shape_rect, background_color, true)
