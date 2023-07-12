@tool
extends Behavior
class_name StateBehavior


## Signal that gets emitted when the state becomes active
signal entered

## Signal that gets emitted when the state becomes inactive.
## Use `transition_id` to determine in the transitions' condition which transition to trigger.
signal exited(target_state_name: String)

## Modelles whether the state reacts to transitions at all.
## The sum of all `active` variables is the state of the state machine
## Use this variable to determine the initial state.
@export var active: bool = false:
	get: return active
	set(value): 
		active = value
		reload_icon()

var _active_texture: ImageTexture = ImageTexture.create_from_image(Image.load_from_file("res://addons/pronto/icons/StateActive.svg"))
var _inactive_texture: ImageTexture  = ImageTexture.create_from_image(Image.load_from_file("res://addons/pronto/icons/StateInactive.svg"))

## Function that tells the state to become active. Works only if the state is not active yet.
func enter():
	if not active:
		active = true
		entered.emit()

## Function that tells the state to become inactive. Works only if the state is active.
## The `transition_id` is forwarded to the `exited` signal and can thus be used to determine
## which transition to trigger.
func exit(target_state_name: String):
	if active:
		active = false
		exited.emit(target_state_name)

## Override of the corresponding method in Behavior.gd
## Used to display the node name of a target StateBehavior on a line
func line_text_function(connection: Connection) -> Callable:
	var addendum = ""
	if get_node(connection.to) is StateBehavior:
		addendum = "\ntransition to '%s'" % connection.to.get_name(connection.to.get_name_count() - 1)
	
	return func(flipped):
		return connection.print(flipped) + addendum

func _get_connected_states(seen_nodes = []):
	seen_nodes.append(self)
	for connection in Connection.get_connections(self):
		var target = get_node_or_null(connection.to)
		if target is StateBehavior and target not in seen_nodes:
			target._get_connected_states(seen_nodes)
	return seen_nodes

## Override of the corresponding method in Behavior.gd
## Used to display the correct icon when the StateBehavior is active or inactive
func icon_texture():
	return _active_texture if active else _inactive_texture

func _ready():
	super._ready()
	
	if active:
		entered.emit()
