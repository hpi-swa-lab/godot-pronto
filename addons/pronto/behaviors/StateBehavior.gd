@tool
#thumb("Slot")
extends Behavior
class_name StateBehavior

## The StateBehavior is the fundamental building block of a state machine.
## 
## Each StateBehavior emits the signals [signal StateBehavior.entered] and
## [signal StateBehavior.exited] to communicate the state machine's state, as
## well as [signal StateBehavior.in_state], while it is active.  
## The active state is managed by its parent node, which must be a
## StateMachineBehavior.

## Signal that gets emitted when the state becomes active
signal entered

## Signal that gets emitted when the state becomes inactive.
signal exited(next_state_name: String)

## Signal that gets emitted every frame while the state is active.
signal in_state(delta: float)

## Signal that gets emitted when the state machine receives a trigger and this
## is the active state.
## Use this to transition to different states.
signal on_trigger_received(trigger: String)

## Use this variable to determine the initial state.
@export var is_initial_state: bool = false:
	set(value):
		active = value
		is_initial_state = value
		if get_parent() is StateMachineBehavior:
			get_parent()._redraw_states_from_editor()

## Models whether the state reacts to transitions at all.
var active: bool = false:
	get: 
		if get_parent():
			return get_parent().active_state == self
		else:
			return false
	set(value): 
		if get_parent():
			get_parent()._set_active_state(self, value)

var _active_texture = load("res://addons/pronto/icons/StateActive.svg")
var _inactive_texture = load("res://addons/pronto/icons/StateInactive.svg")

func _get_configuration_warnings() -> PackedStringArray:
	if not get_parent() is StateMachineBehavior:
		return ["StateBehavior must be child of a StateMachineBehavior"]
	return []

## Function that tells the state to become active.
## Will not do anything if the state is already active.
func enter():
	if not active:
		active = true
		entered.emit()

## Call the exited signal.
func _exit(next_state_name: String):
	if active:
		exited.emit(next_state_name)

## Override of [method Behavior.line_text_function].
## Used to display special text on transitions.
func line_text_function(connection: Connection) -> Callable:
	var addendum = ""
	if connection.is_state_transition():
		addendum = "\ntransition on '%s'" % connection.trigger
		var only_if_source_code = connection.only_if.source_code
		if only_if_source_code != "true":
			if Utils.count_lines(only_if_source_code) == 1:
				addendum += " if " + only_if_source_code
			else:
				addendum += " if [?]"
	
	return func(flipped):
		return connection.print(flipped) + addendum

## Override of [method Behavior.lines] 
## Used to add the State name below the icon and change the color.
func lines():
	var connection_lines = super.lines()
	# Color state transitions specially
	for line in connection_lines:
		if line.to is StateBehavior and line.from is StateBehavior:
			line.color = Color.LIGHT_GREEN
	return connection_lines + [Lines.BottomText.new(self, str(name))]
	
func _get_connected_states(seen_nodes = []):
	seen_nodes.append(self)
	for connection in Connection.get_connections(self):
		var target = get_node_or_null(connection.to)
		if target is StateBehavior and target not in seen_nodes:
			target._get_connected_states(seen_nodes)
	return seen_nodes

## Override of the corresponding method in Behavior.gd
## Used to display the correct icon when the StateBehavior is initial state.
## The icon is set with the _reload_icon_from_game method from the game
## via ConnectionDebug.gd.
func icon_texture():
	return _active_texture if is_initial_state else _inactive_texture
	
func _reload_icon_from_game(value: bool):
	var icon = _active_texture if value else _inactive_texture
	self.reload_icon(icon)

func _ready():
	super._ready()
	
	if is_initial_state:
		if get_parent():
			enter()

func _process(delta):
	super._process(delta)
	
	if not Engine.is_editor_hint() and active:
		in_state.emit(delta)
