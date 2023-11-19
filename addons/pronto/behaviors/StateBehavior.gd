@tool
#thumb("Slot")
extends Behavior
class_name StateBehavior

## The StateBehavior is the fundamental building block of a state machine.
## 
## Each StateBehavior emits the signals [signal StateBehavior.entered] and
## [signal StateBehavior.exited] to communicate the state machine's state

## Signal that gets emitted when the state becomes active
signal entered

## Signal that gets emitted when the state becomes inactive.
## Use [param transition_id] to determine in the transitions' condition which transition to trigger.
signal exited(target_state_name: String)

## Signal that gets emitted every frame while the state is active.
signal in_state(delta: float)

## Signal that gets emitted when the state machine receives a trigger and this
## is the active state.
## Use this to tranistion to different states.
signal on_trigger_received(trigger: String)

## Use this variable to determine the initial state.
@export var is_initial_state: bool = false:
	set(value):
		active = value
		is_initial_state = value

## Models whether the state reacts to transitions at all.
var active: bool = false:
	get: 
		if get_parent():
			return get_parent().active_state == self
		else:
			return false
	set(value): 
		if get_parent():
			get_parent().set_active_state(self, value)
		reload_icon()

var _active_texture = load("res://addons/pronto/icons/StateActive.svg")
var _inactive_texture = load("res://addons/pronto/icons/StateInactive.svg")

func _get_configuration_warning() -> String:
	return "A custom node configuration warning!"

## Function that tells the state to become active. Works only if the state is not active yet.
func enter():
	if not active:
		active = true
		entered.emit()

## DEPRECATED
func exit(target_state_name: String):
	reload_icon()
	if active:
		exited.emit(target_state_name)

## Override of [method Behavior.line_text_function].
## Used to display the node name of a target StateBehavior on a line
func line_text_function(connection: Connection) -> Callable:
	var addendum = ""
	if get_node(connection.to) is StateBehavior:
		addendum = "\ntransition to '%s'" % connection.to.get_name(connection.to.get_name_count() - 1)
	
	return func(flipped):
		# TODO: Custom state transition connections?
		return connection.print(flipped) + addendum

## Override of [method Behavior.lines] 
## Used to add the State name below the icon
func lines():
	return super.lines() + [Lines.BottomText.new(self, str(name))]
	
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
	
	if is_initial_state:
		if get_parent():
			get_parent().set_active_state(self, true)
		
		
func _process(delta):
	super._process(delta)
	
	if not Engine.is_editor_hint() and active:
		in_state.emit(delta)
