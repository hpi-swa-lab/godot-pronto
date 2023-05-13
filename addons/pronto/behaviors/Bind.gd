@tool
#thumb("EditBezier")
extends Behavior
class_name Bind

### Script to evaluate to find the current property value to set.
@export var evaluate: GDScript
### Property of the parent node to write the result of evaluate to.
@export var to_prop: String
### Update only when the update() function is called.
@export var one_shot: bool = false

var _last = null
var _dummy_object

func _ready():
	super._ready()
	if evaluate == null:
		evaluate = Connection.create_script_for(self, "return null", "")
	if _dummy_object == null:
		_dummy_object = U.new(self)
		_dummy_object.set_script(evaluate)

func update():
	_dummy_object.ref = self
	var value = _dummy_object.run()
	
	if _last == value:
		return
	
	get_parent().set(to_prop, value)
	_last = value

func _process(delta):
	super._process(delta)
	
	if not Engine.is_editor_hint() and not one_shot:
		update()

func lines():
	return super.lines() + [Lines.DashedLine.new(self, get_parent(), func (flip): return Utils.ellipsize(Connection.print_script(evaluate), 20), "value")]
