@tool
#thumb("Search")
extends Behavior
class_name Inspect

var default_property = 'position'

var _expression
var expression:
	get:
		return _expression
	set(v):
		if v != null:
			_property = '<statement(s)>'
		_expression = v
		notify_property_list_changed()
		update()

var _property
var property = default_property:
	get:
		return _property
	set(v):
		if v != null and v.begins_with('--'):
			# must not select group headers
			return
		if v == '<statement(s)>':
			expression = 'return target.%s' % (property if property else default_property)
			return
		if v != null:
			_expression = null
		_property = v
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

var shape_size = Vector2(100, 100):
	set(v):
		shape_size = v
		queue_redraw()

func _get_property_list():
	var property_list = []
	
	if target:
		var property_names = []
		property_names.push_front('<statement(s)>')
		for _class in Utils.all_classes_of(target):
			var new_property_names = ClassDB.class_get_property_list(_class, true).map(func(_property): return _property.name)
			if not len(new_property_names): continue
			
			property_names.push_back("-- %s --" % _class)
			new_property_names.sort()
			for name in new_property_names:
				if name[0] == name[0].to_upper():
					# not a useful property
					continue
				property_names.push_back(name)
		
		property_list.append({
			'name': 'property',
			'type': TYPE_STRING,
			'usage': PROPERTY_USAGE_DEFAULT,
			'hint': PROPERTY_HINT_ENUM,
			'hint_string': ','.join(property_names)
		})
		
		if property == '<statement(s)>':
			property_list.append({
				'name': 'expression',
				'type': TYPE_STRING,
				'usage': PROPERTY_USAGE_DEFAULT,
				'hint': PROPERTY_HINT_EXPRESSION
			})
	
	# export static properties
	# NOTE: we could also use export keyword for that, but this would add these properties prior to the other group
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

var value_string: String

func _ready():
	if Engine.is_editor_hint():
		# construction convenience: position ourselves below the parent's known bounds
		var parent = get_parent()
		var parent_rect = Utils.global_rect_of(parent)
		var parent_child_rect = parent.get_children().filter(func(child): return child != self).map(func(child): return Utils.global_rect_of(child)).reduce(func(a, b): return a.merge(b), parent_rect)
		self.position = Vector2(0, (parent_child_rect.end.y - parent_rect.end.y + parent_rect.size.y + shape_size.y) / 2)
	
	super._ready()

func _process(delta):
	super._process(delta)
	
	self.update()

func update():
	var new_value_string
	if target:
		var new_value
		if expression:
			if Engine.is_editor_hint():
				# FIXME: eval() does not work in editor mode
				new_value = null
			else:
				new_value = ConnectionsList.eval(expression, ['target'], [self.target], self)
		elif property:
			new_value = self.target.get(property)
		new_value_string = str(new_value)
	else:
		new_value_string = '<no target>'
	if new_value_string == value_string: return
	value_string = new_value_string
	queue_redraw()

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
	
	var labels = [value_string] #["x: 0", "label: text"]
	
	var shape_rect = Rect2(shape_size / -2, shape_size)
	draw_rect(shape_rect, background_color, true)
	
	var padding = 1
	var shadow_thickness = 1
	var string_rect = shape_rect.grow(-(padding + shadow_thickness)).grow_side(SIDE_TOP, -5)
	var font = ThemeDB.fallback_font
	var string_sizes = labels.map(func(label): return font.get_string_size(label))
	string_sizes = string_sizes.map(func(size): return size * Vector2(1, .5))
	var y = 0
	for i in labels.size():
		var label = labels[i]
		var height = string_sizes[i].y
		y += height
		
		# draw text with shadow
		var ds = []
		for dx in range(-shadow_thickness, shadow_thickness * 2):
			for dy in range(-shadow_thickness, shadow_thickness * 2):
				ds.push_back(Vector2(dx, dy))
		ds.push_back(Vector2.ZERO)
		for d in ds:
			draw_string(
				font,
				string_rect.size / -2 + Vector2(0, y - height / 2) + d,
				label,
				HORIZONTAL_ALIGNMENT_LEFT,
				string_rect.size.x,
				10,
				color if d.x == 0 and d.y == 0 else
					(Color.WHITE if color.get_luminance() < 0.6 else Color.BLACK)
			)
