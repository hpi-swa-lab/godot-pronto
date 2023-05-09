@tool
#thumb("Search")
extends Behavior
class_name Watch

@export var expression: String = "return Expression..."

var _value = ""

func _process(delta):
	super._process(delta)
	if not Engine.is_editor_hint():
		var val = str(ConnectionsList.eval(expression, [], [], self))
		EngineDebugger.send_message("pronto:watch_put", [get_path(), val])

func _report_game_value(val):
	_value = val

func lines():
	return super.lines() + [Lines.BottomText.new(self, Utils.ellipsize(expression, 12) + "=" + _value)]
