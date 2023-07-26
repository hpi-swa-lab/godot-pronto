@tool
#thumb("Timer")
extends Behavior
class_name ClockBehavior

## The ClockBehavior is a [class Behavior] that encasulates a [class Timer]
## and makes it accessible to other behaviors.

## Emitted on [method Timer.timeout]
signal elapsed()

## Emitted in one of two cases:
##
## 1. If [member ClockBehavior.trigger_every_frame] is set to [code]true[/code],
## then this is emitted every frame that the timer is active.
##
## 2. If [member ClockBehavior.trigger_every_x_seconds] is set to [code]true[/code],
## then this is emitted if the last trigger was [member ClockBehavior.trigger_interval_in_seconds] 
## seconds ago.
signal until_elapsed()


var _trigger_inteval: float = 1.0

var _time_since_last_trigger: float = 0

var _trigger_count := 0

## How often the signal [signal ClockBehavor.elapsed] will be emitted.
## A value of [code]-1[/code] means no limit.
@export var cycle_count : int = -1

## Timer duration in seconds
@export var duration_seconds: float = 1.0:
	get: return _timer.wait_time
	set(value): _timer.wait_time = max(value, 0.0001)

## If set to [code]true[/code], the timere will pause itself and resume
## as soon as it is set to [code]false[/code] again.
@export var paused: bool:
	get: return _timer.paused
	set(value): _timer.paused = value

@export_category("Until Elapsed")

## Determines the mode of operation. If this is set to [code]true[/code],
## the normal timer functionality is used.
##
## Mutual exclusive to [member ClockBehavior.trigger_every_x_seconds]
@export var trigger_every_frame: bool:
	get: return trigger_every_frame
	set(value): 
		trigger_every_frame = value
		if value:
			trigger_every_x_seconds = false

## Determines the mode of operation. If this is set to [code]true[/code],
## the custom "trigger every x seconds" functionality is used. This means
## the ClockBehavior will emit [signal ClockBehavior.until_elapsed] when the
## last emit of that signal was at least [member ClockBehavior.trigger_interval_in_seconds]
## seconds ago.
##
## Mutual exclusive to [member ClockBehavior.trigger_every_frame]
@export var trigger_every_x_seconds: bool:
	get: return trigger_every_x_seconds
	set(value): 
		trigger_every_x_seconds = value
		if value:
			trigger_every_frame = false

## If [member ClockBehavior.trigger_every_x_seconds] is set to [code]true[/code],
## this determines the interval in which [signal ClockBehavior.until_elapsed] is
## emitted
@export var trigger_interval_in_seconds: float:
	get: return _trigger_inteval
	set(value): _trigger_inteval = value

var _timer: Timer:
	get:
		if not _timer: _timer = Timer.new()
		return _timer

func reset_and_start():
	self.paused = false
	_trigger_count = 0
	_timer.start(duration_seconds)

func _process(delta):
	super._process(delta)
	
	if((trigger_every_frame or trigger_every_x_seconds) and not (_timer.paused or _timer.is_stopped())):
		if(trigger_every_x_seconds):
			_time_since_last_trigger += delta
			if(_time_since_last_trigger > (_trigger_inteval - delta * 1.1)):
				_time_since_last_trigger = _time_since_last_trigger - _trigger_inteval
				until_elapsed.emit()
		else:
			until_elapsed.emit()

func _ready():
	super._ready()
	if not Engine.is_editor_hint():
		_timer.autostart = true
		_timer.timeout.connect(func(): _on_timer_elapsed())
		add_child(_timer)


func _on_timer_elapsed():
	if cycle_count < 0:
		elapsed.emit()
	elif _trigger_count < cycle_count:
		elapsed.emit()
		_trigger_count += 1
	else:
		_timer.stop()
