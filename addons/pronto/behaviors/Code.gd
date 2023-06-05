@tool
#thumb("ScriptCreateDialog")
extends Behavior
class_name Code

signal after(result)

@export var label: String = ""
@export var arguments: PackedStringArray:
	set(a): if evaluate: evaluate.argument_names = a
	get: return PackedStringArray(evaluate.argument_names) if evaluate else []
@export var evaluate: ConnectionScript

var _dummy_object

func _ready():
	super._ready()
	if evaluate == null:
		evaluate = ConnectionScript.new()
		evaluate.argument_names = arguments
	if _dummy_object == null:
		_dummy_object = U.new(self)
		_dummy_object.set_script(evaluate.nested_script)

func lines():
	return super.lines() + [Lines.BottomText.new(self, label)]

func execute(args: Array):
	assert(args.size() == arguments.size(), "Argument names and values for eval need to have the same size.")
	_dummy_object.ref = self
	var result = _dummy_object.callv("run", args)
	after.emit(result)
