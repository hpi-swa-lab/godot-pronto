@tool
extends Node

func check_install(node: Node):
	for c in Connection.get_connections(node):
		c._install_in_game(node)

func _ready():
	Utils.all_nodes_do(get_tree().root, check_install)
	get_tree().node_added.connect(check_install)

func script_for_eval(source: String, argument_names: Array) -> Script:
	var source_code = '@tool
extends U

func run({0}):
	# GENERATED, DO NOT EDIT
	{1}
'.format([', '.join(argument_names), _indent(source)])
	var source_filename = "res://script-instances/" + str(source_code.hash()) + ".gd"
	if not FileAccess.file_exists(source_filename):
		DirAccess.make_dir_absolute("res://script-instances")
		var script = GDScript.new()
		script.source_code = source_code
		var error = ResourceSaver.save(script, source_filename)
		assert(not error, "Error saving script: %s" % error)
	var script = load(source_filename)
	assert(script, "Could not load script!")
	# TODO: improve error handling
	return script

func eval(source: String, argument_names: Array, argument_values: Array, node_ref = null):
	var result := eval_or_error(source, argument_names, argument_values, node_ref)
	return result.value
	
func eval_or_error(source: String, argument_names: Array, argument_values: Array, node_ref = null) -> ExecResult:
	assert(argument_names.size() == argument_values.size(), "Argument names and values for eval need to have the same size.")
	var key = source + ":" + ','.join(argument_names)
	if not key in _cache:
		var object = U.new(node_ref if node_ref != null else Engine.get_main_loop().root)
		object.set_script(script_for_eval(source, argument_names))
		if "ref" not in object:
			return ExecResult.from_error("Could not create script, possibly a syntax error?")
		_cache[key] = object
	var i = _cache[key]
	i.ref = node_ref
	return ExecResult.from_value(i.callv("run", argument_values))

var _cache = {}

func _indent(s: String):
	return '\n\t'.join(s.split('\n'))

# FIXME very shaky heuristic
func _is_statement(source: String):
	return source.begins_with("for ") or source.begins_with("var ") or " = " in source
