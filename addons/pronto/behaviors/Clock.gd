@tool
#thumb("Timer")
extends Behavior

signal elapsed()
signal until_elapsed()

var _until_elapsed_active: bool = false
var _trigger_inteval: float = 1.0
var _use_trigger_interval: bool = false
var _time_since_last_trigger: float = 0

@export var one_shot: bool:
	get: return _timer.one_shot
	set(value): _timer.one_shot = value
@export var duration_seconds: float = 1.0:
	get: return _timer.wait_time
	set(value): _timer.wait_time = max(value, 0.0001)
@export var paused: bool:
	get: return _timer.paused
	set(value): _timer.paused = value
	
@export_category("Until Elapsed")
@export var trigger_every_frame: bool:
	get: return _until_elapsed_active
	set(value): 
		_until_elapsed_active = value
		if value:
			_use_trigger_interval = false
@export var trigger_every_x_seconds: bool:
	get: return _use_trigger_interval
	set(value): 
		_use_trigger_interval = value
		if value:
			_until_elapsed_active = false
@export var trigger_interval_in_seconds: float:
	get: return _trigger_inteval
	set(value): _trigger_inteval = value

var _timer: Timer:
	get:
		if not _timer: _timer = Timer.new()
		return _timer

func reset_and_start():
	self.paused = false
	_timer.start(duration_seconds)

func _process(delta):
	if((_until_elapsed_active or _use_trigger_interval) and not _timer.paused and not _timer.is_stopped()):
		if(_use_trigger_interval):
			_time_since_last_trigger += delta
			if(_time_since_last_trigger > (_trigger_inteval-delta*1.1)):
				_time_since_last_trigger = _time_since_last_trigger-_trigger_inteval
				until_elapsed.emit()
		else:
			until_elapsed.emit()

func _ready():
	super._ready()
	if not Engine.is_editor_hint():
		_timer.autostart = true
		_timer.timeout.connect(func(): elapsed.emit())
		add_child(_timer)
