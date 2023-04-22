@tool
extends Node

func check_install(node: Node):
	for c in Connection.get_connections(node):
		c._install_in_game(node)

func _ready():
	Utils.all_nodes_do(get_tree().root, check_install)
	get_tree().node_added.connect(check_install)

func script_for_eval(source: String, argument_names: Array, return_value = true):
	var do_ret = return_value and not _is_statement(source)
	var source_code = '# GENERATED, DO NOT EDIT
extends Object
func run({0}):
	{2}{1}'.format([', '.join(argument_names), _indent(source), 'return ' if do_ret else ''])
	var source_filename = "res://script-instances/" + str(source_code.hash()) + ".gd"
	if FileAccess.file_exists(source_filename):
		return load(source_filename)
	else:
		DirAccess.make_dir_absolute("res://script-instances")
		var script = GDScript.new()
		script.source_code = source_code
		ResourceSaver.save(script, source_filename)
		return load(source_filename)

func eval(source: String, argument_names: Array, argument_values: Array, return_value = true):
	assert(argument_names.size() == argument_values.size(), "Argument names and values for eval need to have the same size.")
	var key = source + ":" + ','.join(argument_names)
	if not key in _cache:
		var object = _Dummy.new()
		object.set_script(script_for_eval(source, argument_names, return_value))
		_cache[key] = object
	return _cache[key].callv("run", argument_values)

class _Dummy extends Node: pass
var _cache = {}

func _indent(s: String):
	return '\n\t'.join(s.split('\n'))

# FIXME very shaky heuristic
func _is_statement(source: String):
	return source.begins_with("for ") or source.begins_with("var ") or " = " in source
