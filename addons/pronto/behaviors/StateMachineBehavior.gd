@tool
#thumb("GraphNode")
extends Behavior
class_name StateMachineBehavior

## The StateMachineBehavior is a [class Behavior] that acts as a purely graphic
## hint as to which [class StateBehavior] objects belong to the same state machine.
## The [class GroupDrawer] is used for this.

signal triggered(trigger: String)

var active_state: StateBehavior = null
const always_trigger = "always"
@export var triggers: Array[String] = [always_trigger]

## When true, the state machine will trigger the "always" trigger on every frame,
## allowing state transitions without other triggers.
@export var trigger_always: bool = true

## Exits the current active state and enters the new active state.
## Is usually called by StateBehavior/enter.
func _set_active_state(state: StateBehavior, is_active: bool):
	if active_state:
		active_state._exit(state.name)
	if is_active:
		active_state = state
		state.enter() # Since _set_active_state is usually called from a state's enter(), this won't do anything.
		if EngineDebugger.is_active():
			EngineDebugger.send_message("pronto:state_activation", [get_path(), state.get_path()])

var _state_machine_info = null

func _ready():
	super._ready()
	if Engine.is_editor_hint():
		add_child(preload("res://addons/pronto/helpers/GroupDrawer.tscn").instantiate(), false, INTERNAL_MODE_BACK)
		_state_machine_info = preload("res://addons/pronto/helpers/StateMachineInfo.tscn").instantiate()
		add_child(_state_machine_info, false, INTERNAL_MODE_BACK)

## Provide a trigger to the State Machine. This will trigger the active state
## which may lead to a transition via "on_trigger_received".
func trigger(trigger: String):
	if active_state:
		active_state.on_trigger_received.emit(trigger)
		triggered.emit(trigger)
		if trigger != always_trigger:
			EngineDebugger.send_message("pronto:state_machine_trigger", [get_path(),trigger])

func _get_configuration_warnings() -> PackedStringArray:
	var sum = 0
	for c in get_children():
		if c is StateBehavior and c.is_initial_state:
			sum += 1
	if sum == 0:
		return ["At least one state needs to be marked as the initial state."]
	if sum > 1:
		return ["There can only be one initial state. Currently " + str(sum) + " states are marked as initial state."]
	return []

func _redraw_states_from_editor():
	for c in get_children():
		if c.has_method("reload_icon"):
			c.reload_icon()

func _redraw_states_from_game(active_state: StateBehavior):
	for c in get_children():
		if c.has_method("_reload_icon_from_game"):
			c._reload_icon_from_game(active_state == c)
			
func _redraw_info_from_game(trigger: String):
	if _state_machine_info:
		_state_machine_info._redraw_with_trigger(trigger)

func _process(delta):
	super._process(delta)
	if trigger_always and not Engine.is_editor_hint():
		trigger(always_trigger)
