@tool
extends PanelContainer
class_name StateTransitionConfigurator

static func _open(anchor: Node, undo_redo: EditorUndoRedoManager):
	var i: StateTransitionConfigurator = load("res://addons/pronto/signal_connecting/state_transition_configurator.tscn").instantiate()
	i.anchor = anchor
	i.undo_redo = undo_redo

	# FIXME godot 4.2 beta did not assign a background color to the panel
	var s = G.at("_pronto_editor_plugin").get_editor_interface().get_editor_settings()
	var box = StyleBoxFlat.new()
	box.bg_color = s.get("interface/theme/base_color")
	i.add_theme_stylebox_override("panel", box)

	return i
	
static func open_existing(undo_redo: EditorUndoRedoManager, from: Node, connection: Connection):
	var i: StateTransitionConfigurator = _open(Utils.parent_that(from, func (n): return Utils.has_position(n)), undo_redo)
	i.set_existing_connection(from, connection)
	return i.open(from)

static func open_new_invoke(undo_redo: EditorUndoRedoManager, from: Node, source_signal: Dictionary, receiver: Node):
	var i: StateTransitionConfigurator = _open(Utils.parent_that(receiver, func (n): return Utils.has_position(n)), undo_redo)
	i.selected_signal = source_signal
	i.from = from
	i.receiver = receiver
	i.set_mode()
	i.init_empty_scripts()
	i.reload_triggers()

	return i.open(receiver)
	
static func should_be_opened_with_transition_configurator(node, index):
	var connection = Connection.get_connections(node)[index]
	var isStateTransition = node is StateBehavior and connection["signal_name"] == "on_trigger_received"
	var isOutsideTrigger = connection["invoke"] == "trigger" and node.get_node(connection["to"]) is StateMachineBehavior
	return isStateTransition || isOutsideTrigger
	
func set_mode():
	if receiver is StateMachineBehavior:
		mode = ConfigurationMode.TO_STATE_MACHINE
	else:
		mode = ConfigurationMode.TRANSITION
	redraw_receiver_label()

func open(receiver: Node) -> StateTransitionConfigurator:
	# find existing configurator siblings
	for configurator in Utils.popup_parent(receiver).get_children(true):
		if configurator is StateTransitionConfigurator and configurator.has_same_connection(self):
			configurator.default_focus()
			return configurator

	
	Utils.spawn_popup_from_canvas(receiver, self)
	default_focus()
	return self

var undo_redo: EditorUndoRedoManager

var anchor: Node:
	set(n):
		anchor = n
		reset_size()
var position_offset = Vector2(0, 0)
		
var pinned = false:
	set(value):
		pinned = value
		%Pinned.button_pressed = value

enum ConfigurationMode {TO_STATE_MACHINE, TRANSITION}
var mode: ConfigurationMode = ConfigurationMode.TRANSITION

var from: Node
var existing_connection = null
var more_references: Array = []

var selected_signal: Dictionary:
	set(value):
		selected_signal = value
		%Signal.text = value["name"]

var receiver: Object:
	set(value):
		receiver = value
		redraw_receiver_label()

func redraw_receiver_label():
	if mode == ConfigurationMode.TO_STATE_MACHINE:
		%ReceiverLabel.text = "Input in to state machine ${0} ({1})".format([from.get_path_to(receiver), receiver.name])
	else:
		%ReceiverLabel.text = "Connecting to state ${0} ({1})".format([from.get_path_to(receiver), receiver.name])

func set_existing_connection(from: Node, connection: Connection):
	self.from = from
	existing_connection = connection
	self.selected_signal = Utils.find(from.get_signal_list(), func (s): return s["name"] == connection.signal_name)
	%Condition.edit_script = connection.only_if
	if connection.is_target():
		receiver = from.get_node(connection.to)
	set_mode()
	#for i in connection.more_references:
	#	more_references.append(i)
	#update_argument_names()
	
	%Enabled.button_pressed = connection.enabled
	
	# FIXME just increment total directly didn't work from the closure?!
	var total = {"total": 0}
	Utils.all_nodes_do(ConnectionsList.get_viewport(),
		func(n):
			total["total"] += Connection.get_connections(n).count(connection))
	#%SharedLinksNote.visible = total["total"] > 1
	#%SharedLinksCount.text = "This connection is linked to {0} other node{1}.".format([total["total"] - 1, "s" if total["total"] != 2 else ""])
	reload_triggers()
	if connection.trigger != "":
		for i in range(%TriggerSelection.item_count):
			if %TriggerSelection.get_item_text(i) == connection.trigger:
				%TriggerSelection.select(i)
	
	mark_changed(false)

func empty_script(expr: String, return_value: bool):
	var script := ConnectionScript.new([], return_value, expr)
	#script.argument_types = argument_types()
	return script

func init_empty_scripts():
	%Condition.edit_script = empty_script("true", true)

func get_trigger_argument_script(trigger):
	var argument = empty_script("'%s'" % trigger, true)
	argument.argument_names = ["from", "to"]
	argument.argument_types = ["Node", "Node"]
	return argument

func save():
	var trigger = %TriggerSelection.get_item_text(%TriggerSelection.get_selected_id())

	if existing_connection:
		Utils.commit_undoable(undo_redo, "Update condition of connection", existing_connection.only_if,
			{"source_code": %Condition.text}, "reload")
		var connection_object
		if mode == ConfigurationMode.TO_STATE_MACHINE:
			connection_object = {
					"expression": null,
					"invoke": "trigger",
					"signal_name": %Signal.text,
					"more_references": more_references,
					"arguments": [get_trigger_argument_script(trigger)]
				}
		else:
			connection_object =  {
				"expression": null,
				"invoke": "enter",
				"signal_name": %Signal.text,
				"more_references": more_references,
				"trigger" : trigger
			}
		Utils.commit_undoable(undo_redo,
			"Update connection {0}".format([selected_signal["name"]]),
			existing_connection,
			connection_object
			)
	else:
		if mode == ConfigurationMode.TO_STATE_MACHINE:
			existing_connection =Connection.connect_target(
				from,
				selected_signal["name"],
				from.get_path_to(receiver),
				"trigger",
				[get_trigger_argument_script(trigger)],
				more_references,
				%Condition.updated_script(from, selected_signal["name"]), undo_redo
			)
		else:
			existing_connection = Connection.create_transition(
				from,
				selected_signal["name"],
				from.get_path_to(receiver),
				"enter",
				more_references,
				%Condition.updated_script(from, selected_signal["name"]),
				trigger,
				undo_redo
			)
	existing_connection.enabled = %Enabled.button_pressed
	# FIXME doesn't respect undo
	ConnectionsList.emit_connections_changed()
	mark_changed(false)
	
func reload_triggers():
	%TriggerSelection.clear()
	var state_machine = get_state_machine()
	if not state_machine: return
	for trigger in get_state_machine().triggers:
		%TriggerSelection.add_item(trigger)

func mark_changed(value: bool = true):
	%ChangesNotifier.visible = value

func default_focus():
	await get_tree().process_frame
	%TriggerEdit.grab_focus()

func get_state_machine() -> StateMachineBehavior:
	if from and from.get_parent() is StateMachineBehavior:
		return from.get_parent()
	if receiver is StateMachineBehavior:
		return receiver
	return null

func _on_add_trigger_pressed():
	var new_trigger = %TriggerEdit.text
	if new_trigger not in get_state_machine().triggers:
		get_state_machine().triggers.push_back(new_trigger)
		%TriggerSelection.add_item(new_trigger)
	%TriggerEdit.text = ""

func _on_done_pressed():
	save()
	if not pinned:
		queue_free()

func _on_remove_pressed():
	if existing_connection:
		existing_connection.delete(from, undo_redo)
	queue_free()

func _on_cancel_pressed():
	queue_free()
	
func _on_open_in_connection_editor_pressed():
	if existing_connection:
		NodeToNodeConfigurator.open_existing(undo_redo, from, existing_connection)
	else:
		NodeToNodeConfigurator.open_new_invoke(undo_redo, from, selected_signal,receiver)
	queue_free()

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if not anchor: return
	
	visible = anchor.is_inside_tree()
	if anchor.is_inside_tree():
		position = Utils.popup_position(anchor) + position_offset
		var offscreen_delta = (position + size - get_parent().size).clamp(Vector2(0, 0), Vector2(1000000, 1000000))
		position -= offscreen_delta

	var _parent = Utils.popup_parent(anchor)
	if not _parent: return
	var hovered_nodes = _parent.get_children(true).filter(func (n):
		if not (n is NodeToNodeConfigurator): return false
		return n.get_global_rect().has_point(get_viewport().get_mouse_position()))
	var is_hovered = hovered_nodes.size() > 0 and hovered_nodes[-1] == self
	if is_hovered:
		if self.existing_connection:
			Utils.get_behavior(from).highlight_activated(self.existing_connection)

