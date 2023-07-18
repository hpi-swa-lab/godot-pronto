@tool
#thumb("Search")
extends Behavior
class_name WatchBehavior

## The Watchbehavior is a [class Behavior] that calculates a given script's results
## and puts it into the [class EngineDebugger] for every frame

## The script to evaluate whose results get printed
@export var evaluate: ConnectionScript

var _value = ""
var _last

func _ready():
	super._ready()
	if evaluate == null:
		evaluate = ConnectionScript.new()

func _process(delta):
	super._process(delta)
	if not Engine.is_editor_hint():
		var val = str(evaluate.run([], self))
		if _last != val:
			if EngineDebugger.is_active(): EngineDebugger.send_message("pronto:watch_put", [get_path(), val])
			_last = val

func _report_game_value(val):
	_value = val

func lines():
	return super.lines() + [Lines.BottomText.new(self, Utils.ellipsize(evaluate.source_code, 12) + "=" + _value)]
