extends Resource
class_name ConnectionScript

@export var nested_script: GDScript
@export var argument_names: PackedStringArray
@export var return_value = true
@export var source_code: String:
	get:
		var body = _dedent(nested_script.source_code.substr(nested_script.source_code.find(":\n") + 2).left(-1))
		if body.count('\n') == 0 and body.begins_with("return "):
			return body.substr("return ".length())
		else:
			return body
	set(body):
		var needs_return = return_value and body.count("\n") == 0
		nested_script.source_code = TEMPLATE.format([
			_indent(body),
			', '.join(argument_names),
			"return " if needs_return else ""])

const TEMPLATE = "extends U
func run({1}):
	{2}{0}
"

func reload():
	nested_script.reload()

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
