@tool
#thumb("Search")
extends Behavior
class_name QueryBehavior


signal found(node, token)
signal found_all(nodes, token)

var only_below = null:  # Optional[NodePath]
	set(v):
		only_below = v
		notify_property_list_changed()
var include_internal = null  # Boolean if only_below else null
var group = null  # Optional[StringName]
var clazz = null  # Optional[StringName]
var proximity = null:  # Optional[StringName] # null, 'radius', or 'shapes'
	set(v):
		proximity = v
		if proximity != 'radius':
			self.radius = null
		notify_property_list_changed()
var radius = null:  # Optional[float]
	set(v):
		radius = v
		if v != null:
			self.proximity = 'radius'
		queue_redraw()
var shapes:
	get:
		var _shapes = _reference.get_children().filter(func (child):
			return child is Shape2D
		)
		return _shapes if _shapes else null
var shapes_info:
	get:
		return ",".join(shapes) if shapes else "(add ≥1 shape child)"
var predicate_for_node = null  # Optional[ConnectionScript]

var max_results = null:  # Optional[int]
	set(v):
		max_results = v
		if max_results != null and selection_strategy == null:
			print("setting selection_strategy to 'top'")
			self.selection_strategy = 'top'
		notify_property_list_changed()
var selection_strategy = null:  # Optional[StringName] # null, 'top', or 'random'
	set(v):
		selection_strategy = v
		if selection_strategy == 'top' and priority_strategy == null:
			print("setting priority_strategy to 'distance'")
			self.priority_strategy = 'distance'
		elif selection_strategy == 'random' and random_weight_strategy == null:
			self.random_weight_strategy = 'inverse_distance'
		if selection_strategy != 'top':
			self.priority_strategy = null
		if selection_strategy != 'random':
			self.random_weight_strategy = null
		notify_property_list_changed()
var priority_strategy = null:  # Optional[Union['distance', 'custom']]
	set(v):
		priority_strategy = v
		if priority_strategy != null:
			self.selection_strategy = 'top'
		if priority_strategy != 'custom':
			self.priority_script = null
		notify_property_list_changed()
var priority_script = null:  # Optional[ConnectionScript]
	set(v):
		priority_script = v
		if priority_script != null:
			self.priority_strategy = 'custom'
		notify_property_list_changed()
var random_weight_strategy = null:  # Optional[Union[null, 'inverse_distance', 'custom']]
	set(v):
		random_weight_strategy = v
		if random_weight_strategy != null:
			self.selection_strategy = 'random'
		if random_weight_strategy != 'custom':
			self.random_weight_script = null
		notify_property_list_changed()
var random_weight_script = null:  # Optional[ConnectionScript]
	set(v):
		random_weight_script = v
		if random_weight_script != null:
			self.random_weight_strategy = 'custom'
		notify_property_list_changed()

## A node inside the scene to be used for navigation. Relevant for internal copies only.
var _reference = null

func _get_property_list():
	var property_list = []
	
	property_list.append({
		'name': "Search",
		'type': TYPE_NIL,
		'usage': PROPERTY_USAGE_GROUP,
	})
	property_list.append({
		'name': 'only_below',
		'type': TYPE_NODE_PATH,
		'usage': PROPERTY_USAGE_DEFAULT | PROPERTY_USAGE_CHECKABLE
	})
	if only_below:
		property_list.append({
			'name': 'include_internal',
			'type': TYPE_BOOL,
			'default': false
		})
	property_list.append({
		'name': 'group',
		'type': TYPE_STRING_NAME,
		'usage': PROPERTY_USAGE_DEFAULT | PROPERTY_USAGE_CHECKABLE,
		'hint': PROPERTY_HINT_ENUM_SUGGESTION,
		'hint_string': ','.join(Utils.all_used_groups(_reference)) if _reference else null
	})
	property_list.append({
		'name': 'clazz',
		'type': TYPE_STRING_NAME,
		'usage': PROPERTY_USAGE_DEFAULT | PROPERTY_USAGE_CHECKABLE,
		'hint': PROPERTY_HINT_ENUM,
		'hint_string': ','.join(Utils.all_node_classes())
	})
	property_list.append({
		'name': 'predicate_for_node',  # WORKAROUND: poor man's description (https://godotforums.org/d/32557-how-to-add-custom-description-to-properties-from-get-property-list)
		'type': TYPE_OBJECT,
		'usage': PROPERTY_USAGE_DEFAULT | PROPERTY_USAGE_CHECKABLE,
		'hint': PROPERTY_HINT_RESOURCE_TYPE,
		'hint_string': 'ConnectionScript'
	})
	property_list.append({
		'name': 'proximity',
		'type': TYPE_STRING_NAME,
		'default': null,
		'usage': PROPERTY_USAGE_DEFAULT | PROPERTY_USAGE_CHECKABLE,
		'hint': PROPERTY_HINT_ENUM,
		'hint_string': 'radius,shapes'
	})
	if proximity == 'radius':
		property_list.append({
			'name': 'radius',
			'type': TYPE_FLOAT,
			'default': 10,
			'usage': PROPERTY_USAGE_DEFAULT,
			'hint': PROPERTY_HINT_RANGE,
			'hint_string': '0,%s,or_greater' % Utils.get_game_size().length()
		})
	elif proximity == 'shapes':
		property_list.append({
			'name': 'shapes_info',
			'type': TYPE_STRING,
			'usage': PROPERTY_USAGE_DEFAULT | PROPERTY_USAGE_READ_ONLY
		})
	
	property_list.append({
		'name': "Selection",
		'type': TYPE_NIL,
		'usage': PROPERTY_USAGE_GROUP,
	})
	property_list.append({
		'name': 'max_results',
		'type': TYPE_INT,
		'default': null,
		'usage': PROPERTY_USAGE_DEFAULT | PROPERTY_USAGE_CHECKABLE,
		'hint': PROPERTY_HINT_RANGE,
		'hint_string': '1,10,or_greater'
	})
	if max_results != null:
		property_list.append({
			'name': 'selection_strategy',
			'type': TYPE_STRING_NAME,
			'default': 'top',
			'usage': PROPERTY_USAGE_DEFAULT,
			'hint': PROPERTY_HINT_ENUM,
			'hint_string': 'top,random'
		})
		if selection_strategy == 'top':
			property_list.append({
				'name': 'priority_strategy',
				'type': TYPE_STRING_NAME,
				'default': 'distance',
				'usage': PROPERTY_USAGE_DEFAULT,
				'hint': PROPERTY_HINT_ENUM,
				'hint_string': 'distance,custom'
			})
			if priority_strategy == 'custom':
				property_list.append({
					'name': 'priority_script',
					'type': TYPE_OBJECT,
					'usage': PROPERTY_USAGE_DEFAULT,
					'hint': PROPERTY_HINT_RESOURCE_TYPE,
					'hint_string': 'ConnectionScript'
				})
		elif selection_strategy == 'random':
			property_list.append({
				'name': 'random_weight_strategy',
				'type': TYPE_STRING_NAME,
				'default': 'inverse_distance',
				'usage': PROPERTY_USAGE_DEFAULT,
				'hint': PROPERTY_HINT_ENUM,
				'hint_string': 'inverse_distance,custom'
			})
			if random_weight_strategy == 'custom':
				property_list.append({
					'name': 'random_weight_script',
					'type': TYPE_OBJECT,
					'usage': PROPERTY_USAGE_DEFAULT,
					'hint': PROPERTY_HINT_RESOURCE_TYPE,
					'hint_string': 'ConnectionScript'
				})
	
	return property_list

func wants_expression_inspector(property_name):
	return property_name in ['predicate_for_node', 'priority_script', 'random_weight_script']

func initialize_connection_script(property_name, connection_script):
	connection_script.argument_names = ['node']
	connection_script.argument_types = ['Node2D']

func _ready():
	super._ready()
	
	if _reference == null:
		_reference = self
	
	get_tree().node_added.connect(_node_added)
	get_tree().node_removed.connect(_node_removed)

func query(token = null, parameters = {}):
	var nodes = _query(parameters)
	found_all.emit(nodes, token)
	for node in nodes:
		found.emit(node, token)

func _query(parameters = null):
	if parameters:
		var query = duplicate()
		query._reference = _reference
		for key in parameters.keys():
			query[key] = parameters[key]
		return query._query()


	var nodes = _search()
	nodes = _select(nodes)
	return nodes

func _search():
	var root = _reference.get_node(only_below) if only_below != null else _reference.get_tree().current_scene
	var nodes = Utils.all_nodes(root, include_internal if include_internal != null else false)
	
	if group != null:
		nodes = nodes.filter(func (node):
			return node.is_in_group(group)
		)
	
	if clazz != null:
		nodes = nodes.filter(func (node):
			return node.is_class(clazz)
		)
	
	if predicate_for_node != null:
		nodes = nodes.filter(func (node):
			return predicate_for_node.run([node], self)
		)
	
	if proximity == 'radius':
		nodes = nodes.filter(func (node):
			return node.global_position.distance_to(_reference.global_position) <= radius
		)
	elif proximity == 'shapes':
		# TODO: get this to work. Shape2Ds are no nodes. What nodes would the user have to add? Is there a generic way to do this?
		nodes = nodes.filter(func (node):
			var node_shape
			if node is Shape2D:
				node_shape = node
			else:
				var rect = Utils.get_global_rect(node)
				node_shape = RectangleShape2D.new()
				node_shape.position = node.global_position
				node_shape.size = rect.size
			return shapes.any(func (shape):
				return shape.collide(Transform2D.IDENTITY, node_shape, Transform2D.IDENTITY)
			)
		)
	
	return nodes

func _select(nodes):
	if max_results == null:
		return nodes
	
	var n = min(max_results, len(nodes))
	
	if selection_strategy == 'top':
		var priority_func
		if priority_strategy == 'distance':
			priority_func = func (node):
				return node.global_position.distance_to(_reference.global_position)
		elif priority_strategy == 'custom':
			priority_func = func (node):
				return priority_script.run([node], self)
		nodes.sort_custom(func (a, b): return priority_func.call(a) < priority_func.call(b))
		return nodes.slice(0, n)
	
	elif selection_strategy == 'random':
		var random_weight_func
		if random_weight_strategy == 'inverse_distance':
			random_weight_func = func (node):
				return 1 / node.global_position.distance_to(_reference.global_position)
		elif random_weight_strategy == 'custom':
			random_weight_func = func (node):
				return random_weight_script.run([node], self)
		return Utils.random_sample(nodes, n, random_weight_func)
	
	return nodes

func _draw():
	if is_being_edited():
		if radius != null:
			# FOR LATER: offer handle to change radius
			draw_circle(Vector2.ZERO, radius, Color(1, 1, 1, 0.5))
	super._draw()

func _node_added(node):
	if Engine.is_editor_hint():
		if shapes:
			proximity = 'shapes'

func _node_removed(node):
	if Engine.is_editor_hint():
		if not shapes:
			proximity = null

func selected():
	super.selected()
	queue_redraw()

func deselected():
	super.deselected()
	queue_redraw()


# TODOS
# - implement or remove shapes
# - test everything thoroughly
