@tool
#thumb("Signals")
extends Behavior
class_name SignalBehavior


@export var enabled = true

signal triggered(arg0, arg1, arg2, arg3)

func trigger():
	trigger4(null, null, null, null)

func trigger1(arg0):
	trigger4(arg0, null, null, null)

func trigger2(arg0, arg1):
	trigger4(arg0, arg1, null, null)

func trigger3(arg0, arg1, arg2):
	trigger4(arg0, arg1, arg2, null)

func trigger4(arg0, arg1, arg2, arg3):
	if enabled:
		triggered.emit(arg0, arg1, arg2, arg3)
