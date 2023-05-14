@tool
#thumb("Search")
extends Behavior
class_name Watch

@export var evaluate: GDScript

var _value = ""
var _last
var _dummy_object

func _ready():
	super._ready()
	if evaluate == null:
		evaluate = Connection.create_script_for(self, "null", "", true)
	if _dummy_object == null:
		_dummy_object = U.new(self)
		_dummy_object.set_script(evaluate)

func _process(delta):
	super._process(delta)
	if not Engine.is_editor_hint():
		_dummy_object.ref = self
		var val = str(_dummy_object.run())
		if _last != val:
			EngineDebugger.send_message("pronto:watch_put", [get_path(), val])
			_last = val

func _report_game_value(val):
	_value = val

func lines():
	return super.lines() + [Lines.BottomText.new(self,
		Utils.ellipsize(Connection.print_script(evaluate), 12) + "=" + _value)]
