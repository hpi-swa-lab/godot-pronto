@tool
#thumb("GraphNode")
extends Behavior
class_name StateMachineBehavior

## The StateMachineBehavior is a [class Behavior] that acts as a purely graphic
## hint as to which [class StateBehavior] objects belong to the same state machine.
## The [class GroupDrawer] is used for this.

var active_state: StateBehavior = null
@export var triggers: Array[String] = []

func set_active_state(state: StateBehavior, is_active: bool):
	if active_state:
		active_state.exit(state.name)
	if is_active:
		active_state = state
		state.enter()

func _ready():
	super._ready()
	if Engine.is_editor_hint():
		add_child(preload("res://addons/pronto/helpers/GroupDrawer.tscn").instantiate(), false, INTERNAL_MODE_BACK)
		add_child(preload("res://addons/pronto/helpers/StateMachineInfo.tscn").instantiate(), false, INTERNAL_MODE_BACK)
	ConnectionsList.connections_changed.connect(collect_triggers)

func collect_triggers():
	var connections = Connection.get_connections(self)
	# TODO Get connections *to* this node to get triggers

func states():
	return get_children().filter(func (c): c is StateBehavior)

func trigger(trigger: String):
	if active_state:
		active_state.on_trigger_received.emit(trigger)
