@tool
#thumb("ScriptCreateDialog")
extends Behavior
class_name CodeBehavior

## The CodeBehavior is a [class Behavior] that can run arbitrary code
## and communicates the result with [signal CodeBehavior.after].

## Emittet when the execution of the code returns. [param result] is the result of the execution.
signal after(result)

## The names of the arguments that the code receives. Those can be accessed in [member CodeBehavior.evaluate].
@export var arguments: PackedStringArray:
	set(a): if evaluate: evaluate.argument_names = a
	get: return PackedStringArray(evaluate.argument_names) if evaluate else []

## The Code that gets executed when the [method CodeBehavior.execute] method is called.
@export var evaluate: ConnectionScript

func _ready():
	super._ready()
	if evaluate == null:
		evaluate = ConnectionScript.new()
		evaluate.argument_names = arguments

# Draws the name of the node (from the SceneTree) below the node
func lines():
	return super.lines() + [Lines.BottomText.new(self, self.name)]

## Executes the code provided in [member CodeBehavior.evaluate] and emits the [signal CodeBehavior.after] signal afterwards.
func execute(args: Array):
	assert(args.size() == arguments.size(), "Argument names and values for eval need to have the same size.")
	var result = await evaluate.run(args, self)
	after.emit(result)

func wants_expression_inspector(property_name):
	return property_name == 'evaluate'
