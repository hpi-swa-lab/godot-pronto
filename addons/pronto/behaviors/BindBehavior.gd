@tool
#thumb("EditBezier")
extends Behavior
class_name BindBehavior

## The BindBehavior is a [class Behavior] that helps connecting values from one node
## to properties in another one.

## Script to evaluate to find the current property value to set.
@export var evaluate: ConnectionScript

## Property of the parent node to write the result of evaluate to.
@export var to_prop: String

## Update only when the update() function is called.
@export var one_shot: bool = false

var _last = null

func _ready():
	super._ready()
	if evaluate == null:
		evaluate = ConnectionScript.new([], true)

func update():
	var value = await evaluate.run([], self)
	
	if _last == value:
		return
	
	get_parent().set(to_prop, value)
	_last = value

func _process(delta):
	super._process(delta)
	
	if not Engine.is_editor_hint() and not one_shot:
		update()

func lines():
	return super.lines() + [Lines.DashedLine.new(self, get_parent(), func (flip): return Utils.ellipsize(evaluate.source_code, 20), "value")]

func wants_expression_inspector(property_name):
	return property_name == 'evaluate'
	
