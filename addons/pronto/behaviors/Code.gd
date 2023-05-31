@tool
#thumb("ScriptCreateDialog")
extends Behavior
class_name Code

signal after(result)

@export var arguments: Array[String] = []
@export var code: String = ""

func execute(args: Array):
	assert(args.size() == arguments.size(), "Argument names and values for eval need to have the same size.")
	var result = ConnectionsList.eval(code, arguments, args, self)
	after.emit(result)
