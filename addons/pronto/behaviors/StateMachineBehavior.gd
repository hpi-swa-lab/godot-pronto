@tool
#thumb("GraphNode")
extends Behavior
class_name StateMachineBehavior

## The StateMachineBehavior is a [class Behavior] that acts as a purely graphic
## hint as to which [class StateBehavior] objects belong to the same state machine.
## The [class GroupDrawer] is used for this.

signal triggered(trigger: String)

var active_state: StateBehavior = null
@export var triggers: Array[String] = ["ε"]

## When true, the state machine will trigger the "ε" trigger on every frame,
## allowing state transitions without other triggers.
@export var trigger_epsilon: bool = true

func set_active_state(state: StateBehavior, is_active: bool):
	if active_state:
		active_state.exit(state.name)
	if is_active:
		active_state = state
		state.enter() # Since set_active_state is usually called from a state's enter(), this won't do anything.
		if EngineDebugger.is_active():
			EngineDebugger.send_message("pronto:state_activation", [get_path(), state.get_path()])

func _ready():
	super._ready()
	if Engine.is_editor_hint():
		add_child(preload("res://addons/pronto/helpers/GroupDrawer.tscn").instantiate(), false, INTERNAL_MODE_BACK)
		add_child(preload("res://addons/pronto/helpers/StateMachineInfo.tscn").instantiate(), false, INTERNAL_MODE_BACK)

func states():
	return get_children().filter(func (c): c is StateBehavior)

func trigger(trigger: String):
	if active_state:
		active_state.on_trigger_received.emit(trigger)
		triggered.emit(trigger)

func _redraw_states_from_game(active_state: StateBehavior):
	for c in get_children():
		if c.has_method("_reload_icon_from_game"):
			c._reload_icon_from_game(active_state == c)


func _process(delta):
	super._process(delta)
	if trigger_epsilon:
		trigger("ε")
