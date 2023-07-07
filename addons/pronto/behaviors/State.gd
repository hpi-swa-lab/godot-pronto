@tool
#thumb("CircleShape2D")
extends Behavior
class_name State


## Signal that gets emitted when the state becomes active
signal entered

## Signal that gets emitted when the state becomes inactive.
## Use `transition_id` to determine in the transitions' condition which transition to trigger.
signal exited(transition_id: int)

## Modelles whether the state reacts to transitions at all.
## The sum of all `active` variables is the state of the state machine
## Use this variable to determine the initial state.
@export var active: bool = false:
	get: return active
	set(value): active = value

## Function that tells the state to become active. Works only if the state is not active yet.
func enter():
	if not active:
		active = true
		entered.emit()

## Function that tells the state to become inactive. Works only if the state is active.
## The `transition_id` is forwarded to the `exited` signal and can thus be used to determine
## which transition to trigger.
func exit(transition_id):
	if active:
		active = false
		exited.emit(transition_id)

func _get_connected_states(seen_nodes = []):
	seen_nodes.append(self)
	for connection in Connection.get_connections(self):
		var target = get_node_or_null(connection.to)
		if target is State and target not in seen_nodes:
			target._get_connected_states(seen_nodes)
	return seen_nodes

func _ready():
	super._ready()
	
	if active:
		entered.emit()
