@tool
#thumb("Search")
extends Behavior
class_name QueryBehavior


signal found(node, token)
signal found_all(nodes, token)

var only_below = null:
	set(v):
		only_below = v
		notify_property_list_changed()
var include_internal = null
var radius = null:
	set(v):
		radius = v
		queue_redraw()
var group = null

var top_n = null

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
		'hint_string': ','.join(Utils.all_used_groups())
	})
	property_list.append({
		'name': 'radius',
		'type': TYPE_FLOAT,
		'default': 10,
		'usage': PROPERTY_USAGE_DEFAULT | PROPERTY_USAGE_CHECKABLE,
		'hint': PROPERTY_HINT_RANGE,
		'hint_string': '0,%s,or_greater' % Utils.get_game_size().length()
	})
	
	property_list.append({
		'name': "Selection",
		'type': TYPE_NIL,
		'usage': PROPERTY_USAGE_GROUP,
	})
	property_list.append({
		'name': 'top_n',
		'type': TYPE_INT,
		'default': null,
		'usage': PROPERTY_USAGE_DEFAULT | PROPERTY_USAGE_CHECKABLE,
		'hint': PROPERTY_HINT_RANGE,
		'hint_string': '1,10,or_greater'
	})
	
	return property_list

func query(token = null, parameters = {}):
	var nodes = _search(parameters)
	found_all.emit(nodes, token)
	for node in nodes:
		found.emit(node, token)

func _search(parameters = {}):
	var nodes
	
	var root = get_node(only_below) if only_below != null else get_tree().current_scene
	nodes = Utils.all_nodes(root, include_internal if include_internal != null else false)
	
	if group != null:
		nodes = nodes.filter(func (node):
			return node.is_in_group(group)
		)
	
	if radius != null:
		nodes = nodes.filter(func (node):
			return node.global_position.radius_to(global_position) <= radius
		)
	
	
	if top_n != null:
		nodes.sort_custom(func (a, b):
			return a.global_position.distance_to(_reference.global_position) < b.global_position.distance_to(_reference.global_position)
		)
		nodes = nodes.slice(0, min(top_n, len(nodes)))
	
	
	return nodes

func _draw():
	if is_being_edited():
		if radius != null:
			# FOR LATER: offer handle to change radius
			draw_circle(Vector2.ZERO, radius, Color(1, 1, 1, 0.5))
	super._draw()

func selected():
	super.selected()
	queue_redraw()

func deselected():
	super.deselected()
	queue_redraw()
