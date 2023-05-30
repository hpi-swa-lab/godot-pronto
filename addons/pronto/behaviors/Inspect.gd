@tool
#thumb("Search")
extends Behavior
class_name Inspect

var default_property = 'position'
var default_expression = 'return self.%s' % default_property

var _expressions = []
func get_expression(i):
	if i >= len(_expressions):
		return '<click to add>'
	return _expressions[i]
func set_expression(i, v):
	if v == '<click to add>':
		# must not add placeholder
		return
	if i >= len(_expressions):
		_expressions.push_back(null)
		_properties.push_back(null)
	if v == '<remove>':
		_properties.remove_at(i)
		_expressions.remove_at(i)
	else:
		if v != null:
			_properties[i] = '<statement(s)>'
		_expressions[i] = v
	notify_property_list_changed()
	update()

var _properties = []
func get_property(i):
	if i >= len(_properties):
		return '<click to add>'
	return _properties[i]
func set_property(i, v):
	if v != null and v.begins_with('--'):
		# must not select group headers
		return
	if v == '<click to add>':
		# must not add placeholder
		return
	if i >= len(_properties):
		_expressions.push_back(null)
		_properties.push_back(null)
	if v == '<remove>':
		_properties.remove_at(i)
		_expressions.remove_at(i)
	else:
		if v == '<statement(s)>':
			var property = _properties[i]
			return set_expression(i, 'return target.%s' % (property if property else default_property))
		if v != null:
			_expressions[i] = null
		_properties[i] = v
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
		color = v
		queue_redraw()

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

var label: Label

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
		
		for i in len(_properties) + len(['<template>']):
			var _property_names = property_names.duplicate()
			if len(_properties) > 1 and i < len(_properties):
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
		'name': 'shape_size',
		'type': TYPE_VECTOR2,
		'usage': PROPERTY_USAGE_DEFAULT
	})
	
	return property_list

var strings

func _init():
	super._init()
	
	self.shape_size = Vector2(100, 100)
	_properties.push_back(null)
	_expressions.push_back(null)
	self.set_property(0, default_property)
	
	label = Label.new()
	label.label_settings = LabelSettings.new()
	label.label_settings.font_size = 10
	label.label_settings.line_spacing = -4
	label.autowrap_mode = TextServer.AUTOWRAP_ARBITRARY
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
	var new_strings
	if self.target:
		new_strings = []
		for i in len(_expressions):
			var label
			var value
			if _expressions[i]:
				var expression = _expressions[i]
				label = "<expr%s>" % i
				if Engine.is_editor_hint():
					# FIXME: eval() does not work in editor mode
					value = null
				else:
					value = ConnectionsList.eval(expression, ['target'], [self.target], self)
			elif _properties[i]:
				var property = _properties[i]
				label = property
				value = self.target.get(property)
			var value_string = str(value)
			if i + 1 < len(_expressions): # no need to truncate last item
				value_string = Utils.ellipsize(value_string, 32)
			new_strings.push_back([label, value_string])
	else:
		new_strings = '<no target>'
	if typeof(new_strings) == typeof(strings) and new_strings == strings: return
	strings = new_strings
	
	if label != null:
		var labels = [strings] if not (strings is Array) else strings.map(func(string): return "%s: %s" % string)
		label.set_text("\n".join(labels))

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
