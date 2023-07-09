@tool
#thumb("ScriptCreateDialog")
extends Behavior
class_name Code

## Emittet when the execution of the code returns. Contains the result of the execution as parameter.
signal after(result)

## The names of the arguments that the code receives. Those can be accessed in [code]evaluate[/code].
@export var arguments: PackedStringArray:
	set(a): if evaluate: evaluate.argument_names = a
	get: return PackedStringArray(evaluate.argument_names) if evaluate else []

## The Code that gets executed when [code]execute()[/code] method is called.
@export var evaluate: ConnectionScript

func _ready():
	super._ready()
	if evaluate == null:
		evaluate = ConnectionScript.new()
		evaluate.argument_names = arguments

# Draws the name of the node (from the SceneTree) below the node
func lines():
	return super.lines() + [Lines.BottomText.new(self, self.name)]

## Executes the code provided in [code]evaluate[/code] and emits the [code]after[/code] signal afterwards.
func execute(args: Array):
	assert(args.size() == arguments.size(), "Argument names and values for eval need to have the same size.")
	var result = evaluate.run(args, self)
	after.emit(result)
