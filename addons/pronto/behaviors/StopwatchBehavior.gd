@tool
#thumb("Time")
extends Behavior
class_name StopwatchBehavior

## The StopwatchBehavior is a [class Behavior] that counts time in seconds.

var _start: int = 0

## Time elapsed since the start (in seconds)
var elapsed: float:
	get: return (Time.get_ticks_msec() - _start) / 1000.0 if _start > 0 else 0

func start():
	_start = Time.get_ticks_msec()

func stop():
	_start = 0
