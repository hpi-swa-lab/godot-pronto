extends Node

func check_install(node: Node):
	for c in Connection.get_connections(node):
		c._install_in_game(node)

func _ready():
	Utils.all_nodes_do(get_tree().root, check_install)
	get_tree().node_added.connect(check_install)

class Dummy extends Node: pass
var cache = {}
func eval(source: String, argument_names: Array, argument_values: Array):
	# FIXME could have different order argument names
	if not source in cache:
		var script = GDScript.new()
		script.source_code = 'extends Object
func run({0}):
	{2}{1}'.format([', '.join(argument_names), _indent(source), '' if _is_statement(source) else 'return '])
		script.reload()
		var object = Dummy.new()
		object.set_script(script)
		cache[source] = object
	return cache[source].callv("run", argument_values)

func _indent(s: String):
	return '\n\t'.join(s.split('\n'))

# shaky heuristic
func _is_statement(source: String):
	return source.begins_with("for ") or source.begins_with("var ")
