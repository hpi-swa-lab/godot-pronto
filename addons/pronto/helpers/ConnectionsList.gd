@tool
extends Node

func check_install(node: Node):
	for c in Connection.get_connections(node):
		c._install_in_game(node)

func _ready():
	Utils.all_nodes_do(get_tree().root, check_install)
	get_tree().node_added.connect(check_install)

func eval(source: String, argument_names: Array, argument_values: Array, return_value = true):
	# FIXME could have different order of argument names
	if not source in _cache:
		var script = GDScript.new()
		var do_ret = return_value and not _is_statement(source)
		script.source_code = 'extends Object
func run({0}):
	{2}{1}'.format([', '.join(argument_names), _indent(source), 'return ' if do_ret else ''])
		script.reload()
		var object = _Dummy.new()
		object.set_script(script)
		_cache[source] = object
	return _cache[source].callv("run", argument_values)

class _Dummy extends Node: pass
var _cache = {}

func _indent(s: String):
	return '\n\t'.join(s.split('\n'))

# FIXME very shaky heuristic
func _is_statement(source: String):
	return source.begins_with("for ") or source.begins_with("var ") or " = " in source
