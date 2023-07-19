@tool
#thumb("Search")
extends Behavior
class_name QueryBehavior


## Emitted for each node found, ordered according to the priority strategy.
## [param node] The node that was found.
## [param token] The associated token with the request.
## [param priority] The priority of the node, according to the priority strategy.
## [param selection_arg] The selection argument of the node, e.g., the normalized random weight. Optional.
signal found(node, token, priority, selection_arg)
## Emitted once all nodes have been found.
## [param nodes] The nodes that were found, ordered according to the priority strategy.
## [param token] The associated token with the request.
## [param priorities] The priorities of the nodes, according to the priority strategy.
## [param selection_args] The selection arguments of the nodes, e.g., the normalized random weights. Optional.
signal found_all(nodes, token, priorities, selection_args)
## Emitted if no node was found.
## [param token] The associated token with the request.
signal found_none(token)

## Only search for nodes below this node. If null, search in the entire scene.
var only_below = null:  # Optional[NodePath]
	set(v):
		only_below = v
		notify_property_list_changed()
## Whether to include internal nodes in the search. Only relevant if only_below is set.
var include_internal = null  # Boolean if only_below else null
## Only search for nodes in this group. Optional.
var group = null  # Optional[StringName]
## Only search for nodes of this class. Optional.
var clazz = null  # Optional[StringName]
## Mode for selecting nodes based on their spatial proximity to the reference node. Optional.
var proximity = null:  # Optional[StringName] # null, 'radius', or 'shapes'
	set(v):
		if proximity == v:
			return
		proximity = v
		if proximity != 'radius':
			self.radius = null
		notify_property_list_changed()  # influences presence of radius/shapes
## Only search for nodes within this radius of the reference node. Optional.
var radius = null:  # Optional[float]
	set(v):
		radius = v
		if v != null:
			self.proximity = 'radius'
		queue_redraw()
## Only search for nodes that are colliding with one of these shapes. Optional.
# NOTE: Shapes are not yet implemented. Interface might change. See comment in _search() below.
var shapes:
	get:
		var _shapes = _reference.get_children().filter(func (child):
			return child is Shape2D
		)
		return _shapes if _shapes else null
var shapes_info:
	get:
		return "⚠ not yet implemented"
		#return ",".join(shapes) if shapes else "(add ≥1 shape child)"
## Optional script to filter nodes. Has access to a [code]node[/code] argument and must return a boolean.
var predicate = null  # Optional[ConnectionScript]

## Strategy for ordering found nodes. Optional.
var priority_strategy = 'distance':  # Optional[Union['distance', 'custom']]
	set(v):
		if priority_strategy == v:
			return
		priority_strategy = v
		if priority_strategy != 'custom':
			self.priority_script = null
		notify_property_list_changed()  # influences presence of priority_script
## Optional script to order found nodes. Has access to a [code]node[/code] argument and must return a number. Smaller numbers are prioritized over larger numbers.
var priority_script = null:  # Optional[ConnectionScript]
	set(v):
		priority_script = v
		if priority_script != null:
			self.priority_strategy = 'custom'
## Limit the number of results. Optional.
var max_results = null:  # Optional[int]
	set(v):
		if max_results == v:
			return
		max_results = v
		if max_results != null and selection_strategy == null:
			self.selection_strategy = 'top'
		elif max_results == null:
			self.selection_strategy = null
		notify_property_list_changed()  # influences presence of selection_strategy
## Strategy for selecting nodes when max_results is set.
var selection_strategy = null:  # Optional[StringName] # null, 'top', or 'random'
	set(v):
		if selection_strategy == v:
			return
		selection_strategy = v
		if selection_strategy == 'top' and priority_strategy == null:
			self.priority_strategy = 'distance'
		elif selection_strategy == 'random' and random_weight_strategy == null:
			self.random_weight_strategy = 'uniform'
		if selection_strategy != 'random':
			self.random_weight_strategy = null
		notify_property_list_changed()  # influences presence of random_weight_strategy
## Strategy for weighting nodes when selection_strategy is set to 'random'.
var random_weight_strategy = null:  # Optional[Union[null, 'uniform', 'inverse_distance', 'custom']]
	set(v):
		if random_weight_strategy == v:
			return
		random_weight_strategy = v
		if random_weight_strategy != null:
			self.selection_strategy = 'random'
		if random_weight_strategy != 'custom':
			self.random_weight_script = null
		notify_property_list_changed()  # influences presence of random_weight_script
		if random_weight_strategy == 'custom':
			self.random_weight_script = ConnectionScript.new()
			initialize_connection_script('random_weight_script', self.random_weight_script)
## Script to weight nodes when random_weight_strategy is set to 'custom'. Has access to a [code]node[/code] argument and must return a non-negative number.
var random_weight_script = null:  # Optional[ConnectionScript]
	set(v):
		random_weight_script = v
		if random_weight_script != null:
			self.random_weight_strategy = 'custom'

## A node inside the scene to be used for navigation. Relevant for internal copies only.
var _reference = null

func _get_property_list():
	var property_list = []
	
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
		'name': 'predicate',
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
		if selection_strategy == 'random':
			property_list.append({
				'name': 'random_weight_strategy',
				'type': TYPE_STRING_NAME,
				'default': 'inverse_distance',
				'usage': PROPERTY_USAGE_DEFAULT,
				'hint': PROPERTY_HINT_ENUM,
				'hint_string': 'uniform,inverse_distance,custom'
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
	return property_name in ['predicate', 'priority_script', 'random_weight_script']

func initialize_connection_script(property_name, connection_script):
	connection_script.argument_names = ['node']
	connection_script.argument_types = ['Node2D']
	connection_script.source_code = {
		'predicate': "node != null",
		'priority_script': "node.z_index",
		'random_weight_script': "1"
	}[property_name]

func _ready():
	super._ready()
	
	if _reference == null:
		_reference = self
	
	get_tree().node_added.connect(_node_added)
	get_tree().node_removed.connect(_node_removed)

## Request to find nodes. Can override any property of the query through the [code]parameters[/code] argument.
## Results are emitted through signals.
func query(token = null, parameters = {}):
	var results = _query(parameters)
	var nodes = results[0]
	var priorities = results[1]
	var selection_args = results[2]
	
	found_all.emit(nodes, token, priorities, selection_args)
	if len(nodes) == 0:
		found_none.emit(token)
	else:
		for i in len(nodes):
			var node = nodes[i]
			var priority = priorities[i] if priorities else null
			var selection_arg = selection_args[i] if selection_args else null
			found.emit(node, token, priority, selection_arg)

func _query(parameters = null):
	if parameters:
		var query = duplicate()
		query._reference = _reference
		for key in parameters.keys():
			query[key] = parameters[key]
		return query._query()
	
	
	var nodes = _search()
	
	var nodes_and_priorities = _sort(nodes)
	nodes = nodes_and_priorities[0]
	var priorities = nodes_and_priorities[1]
	
	var nodes_and_selection_args = _select(nodes)
	nodes = nodes_and_selection_args[0]
	var selection_args = nodes_and_selection_args[1]
	if priorities != null:
		for node in priorities.keys():
			if node not in nodes:
				priorities.erase(node)
	
	priorities = priorities.values() if priorities != null else null
	return [nodes, priorities, selection_args]

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
	
	if predicate != null:
		nodes = nodes.filter(func (node):
			return predicate.run([node], self)
		)
	
	if proximity == 'radius':
		nodes = nodes.filter(func (node):
			return node.global_position.distance_to(_reference.global_position) <= radius
		)
	elif proximity == 'shapes':
		# TODO: implement this. Is there a generic way to check whether one of our shapes collides with the shape of a node? If not, we have to maintain the shape ourselves and offer handles in a similar way to SpawnerBehavior. Fix handles there first, and extract this into a reusable unit. Below is untested pseudocode.
		assert(false, "not yet implemented")
		nodes = nodes.filter(func (node):
			var node_shape
			# node_shape = magic_node_to_shape(node)
			if node is Shape2D:
				node_shape = node
			else:
				var rect = Utils.get_global_rect(node)
				node_shape = RectangleShape2D.new()
				node_shape.position = node.global_position
				node_shape.size = rect.size
			return shapes.any(func (shape):
				# again, this is untested. do identity transforms make sense here?
				return shape.collide(Transform2D.IDENTITY, node_shape, Transform2D.IDENTITY)
			)
		)
	
	return nodes

func _sort(nodes):
	if priority_strategy == null:
		return [nodes, null]
	
	var priority_func
	if priority_strategy == 'distance':
		priority_func = func (node):
			return node.global_position.distance_to(_reference.global_position)
	elif priority_strategy == 'custom':
		priority_func = func (node):
			return priority_script.run([node], self)
	
	var priorities = {}
	for node in nodes:
		priorities[node] = priority_func.call(node)
	nodes.sort_custom(func (a, b): return priorities[a] < priorities[b])
	
	return [nodes, priorities]

func _select(nodes):
	if max_results == null:
		return [nodes, null]
	
	var n = min(max_results, len(nodes))
	var selection_args = null
	
	if selection_strategy == 'top':
		nodes = nodes.slice(0, n)
	
	elif selection_strategy == 'random':
		var random_weight_func
		if random_weight_strategy == 'uniform':
			random_weight_func = func (node):
				return 1
		elif random_weight_strategy == 'inverse_distance':
			random_weight_func = func (node):
				return 1 / node.global_position.distance_to(_reference.global_position)
		elif random_weight_strategy == 'custom':
			random_weight_func = func (node):
				return random_weight_script.run([node], self)
		
		nodes = Utils.random_sample(nodes, n, random_weight_func)
		# selection args: normalized random weights
		selection_args = nodes.map(func (node): return random_weight_func.call(node))
		var sum = Utils.sum(selection_args)
		selection_args = selection_args.map(func (arg): return arg * 1.0 / sum)
	
	return [nodes, selection_args]

func _draw():
	if is_being_edited():
		if radius != null:
			# FOR LATER: offer handle to change radius, or extract this into a reusable shape mechanism
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
# - create example
# - comment signals + document new behaviors in readme
# - changelog + video
