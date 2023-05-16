extends Resource
class_name ConnectionScript

@export var nested_script: GDScript
@export var arguments: PackedStringArray
@export var return_value = true

var source_code:
	get:
		return print_script(nested_script)
	set(v):
		nested_script.source_code = script_source_for(v)
		nested_script.reload()

func reload():
	nested_script.reload()

func _init():
	if nested_script == null:
		nested_script = GDScript.new()

func script_source_for(body: String) -> String:
	var needs_return = return_value and body.count("\n") == 0
	return "extends U
func run({1}):
	{2}{0}
".format([_indent(body), ', '.join(arguments), "return " if needs_return else ""])

func _signal_args(from: Node, name: String) -> Array:
	if name == "":
		return []
	return Utils.find(from.get_signal_list(), func (s): return s["name"] == name)["args"].map(func (a): return a["name"])

func _indent(s: String):
	return '\n\t'.join(s.split('\n'))

func _dedent(s: String):
	return '\n'.join(Array(s.split('\n')).map(func(l): return l.right(-1)))

## Heuristic to find the body of the script
func print_script(s: GDScript):
	var body = _dedent(s.source_code.substr(s.source_code.find(":\n") + 2).left(-1))
	if body.count('\n') == 0 and body.begins_with("return "):
		return body.substr("return ".length())
	else:
		return body
