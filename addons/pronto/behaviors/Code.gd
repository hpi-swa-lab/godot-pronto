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

func _ready():
	super._ready()
	if evaluate == null:
		evaluate = ConnectionScript.new()
		evaluate.argument_names = arguments

func lines():
	return super.lines() + [Lines.BottomText.new(self, label)]

func execute(args: Array):
	assert(args.size() == arguments.size(), "Argument names and values for eval need to have the same size.")
	var result = evaluate.run(args, self)
	after.emit(result)
