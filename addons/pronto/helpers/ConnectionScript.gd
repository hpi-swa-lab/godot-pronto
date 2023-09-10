@tool
extends Resource
class_name ConnectionScript

# We can't extend the polymorphic interface of GDScript, so this is our workaround
static func full_source_code(s: Resource, text: String):
	if s is ConnectionScript: return s.get_full_source_code(text)
	else: return text
static func map_row_col(s: Resource, row: int, col: int, do: Callable):
	if s is ConnectionScript:
		do.call(row + 2, col + 1 +
			("return ".length() if s.needs_return(s.source_code) else 0))
	else: do.call(row, col)


@export var nested_script: GDScript
@export var argument_names: Array
var argument_types = null:  # optional Array of StringNames for type hints
	get:
		return argument_types
	set(v):
		argument_types = v
		source_code = source_code  # update source code
@export var return_value = true
var source_code: String:
	get:
		var body = _dedent(nested_script.source_code.substr(nested_script.source_code.find(":\n") + 2).left(-1))
		if body.count('\n') == 0 and body.begins_with("return "):
			return body.substr("return ".length())
		else:
			return body
	set(body):
		nested_script.source_code = get_full_source_code(body)

const TEMPLATE = "@tool
extends U
@warning_ignore(\"unused_parameter\")
func run({1}):
	{2}{0}
"

var has_error = false

func needs_return(body: String):
	return return_value and body.count("\n") == 0 and not body.begins_with("print(") and not body.begins_with("return ")

func get_full_source_code(body: String):
	return TEMPLATE.format([
		_indent(body),
		", ".join(range(argument_names.size()).map(func(i):
			if argument_types == null or i >= len(argument_types) or argument_types[i] == null:
				if argument_types != null: assert(i < len(argument_types), "is this ever called?")
				return argument_names[i]
			# add type hint
			return "{0}: {1}".format([argument_names[i], argument_types[i]]))),
		"return " if needs_return(body) else ""])

var _dummy_object = null
func run(arguments: Array, ref = null):
	if _dummy_object == null:
		_dummy_object = U.new(ref)
		_dummy_object.set_script(nested_script)
	_dummy_object.ref = ref
	return await _dummy_object.callv("run", arguments)

func reload():
	var err = nested_script.reload()
	has_error = err != OK
	return err

func _init(argument_names: PackedStringArray = [], return_value = true, source_code = "null"):
	if nested_script == null:
		nested_script = GDScript.new()
	self.argument_names = argument_names
	self.return_value = return_value
	self.source_code = source_code

func _indent(s: String):
	return '\n\t'.join(s.split('\n'))

func _dedent(s: String):
	return '\n'.join(Array(s.split('\n')).map(func(l): return l.right(-1)))
