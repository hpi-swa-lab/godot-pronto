@tool
extends NodeToNodeConfigurator
class_name StateConnectionConfigurator

@onready var receiver_label = $MarginContainer/VBoxContainer/ReceiverLabel

static func _open(anchor: Node, undo_redo: EditorUndoRedoManager):
	var i = preload("res://addons/pronto/signal_connecting/state_connection_configuration.tscn").instantiate()
	i.anchor = anchor
	i.undo_redo = undo_redo
	
	# FIXME godot 4.2 beta did not assign a background color to the panel
	var s = G.at("_pronto_editor_plugin").get_editor_interface().get_editor_settings()
	var box = StyleBoxFlat.new()
	box.bg_color = s.get("interface/theme/base_color")
	i.add_theme_stylebox_override("panel", box)
	
	return i
	
static func open_existing(undo_redo: EditorUndoRedoManager, from: Node, connection: Connection):
	var i = _open(Utils.parent_that(from, func (n): return Utils.has_position(n)), undo_redo)
	i.set_existing_connection(from, connection)
	return i.open(from)
	
static func open_new_invoke(undo_redo: EditorUndoRedoManager, from: Node, source_signal: Dictionary, receiver: Node):
	var i = _open(Utils.parent_that(receiver, func (n): return Utils.has_position(n)), undo_redo)
	i.selected_signal = source_signal
	i.from = from
	i.receiver = receiver
	i.set_mode(false, true)
	i.init_empty_scripts()
	#i.reload_triggers()
	
	return i.open(receiver)
	
func set_existing_connection(from: Node, connection: Connection):
	super.set_existing_connection(from, connection)
	reload_triggers()
	if connection.trigger != "":
		for i in range(%TriggerSelection.item_count):
			if %TriggerSelection.get_item_text(i) == connection.trigger:
				%TriggerSelection.select(i)

func reload_triggers():
	%TriggerSelection.clear()
	var state_machine = get_state_machine()
	if not state_machine: return
	for trigger in get_state_machine().triggers:
		%TriggerSelection.add_item(trigger)
	
func _set_receiver(value):
	_receiver = value
	if receiver:
		%ReceiverLabel.text = "Connecting to state ${0} ({1})".format([from.get_path_to(receiver), receiver.name])
		%FunctionName.anchor = anchor
		%FunctionName.node = receiver
		
func save():
	%FunctionName.accept_selected()
	var trigger = %TriggerSelection.get_item_text(%TriggerSelection.get_selected_id())

	if existing_connection:
		Utils.commit_undoable(undo_redo, "Update condition of connection", existing_connection.only_if,
			{"source_code": %Condition.text}, "reload")
		Utils.commit_undoable(undo_redo,
			"Update connection {0}".format([selected_signal["name"]]),
			existing_connection,
			{
				"expression": null,
				"invoke": "enter",
				"signal_name": %Signal.text,
				"more_references": more_references,
				"trigger" : trigger
			})
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

# Called when the node enters the scene tree for the first time.
func _ready():
	super._ready()
	reload_triggers()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	super._process(delta)

func get_state_machine() -> StateMachineBehavior:
	if from and from.get_parent() is StateMachineBehavior:
		return from.get_parent()
	return null


func _on_add_trigger_pressed():
	var new_trigger = $MarginContainer/VBoxContainer/TriggerContainer/HBoxContainer/TextEdit.text
	if new_trigger not in get_state_machine().triggers:
		get_state_machine().triggers.push_back(new_trigger)
		%TriggerSelection.add_item(new_trigger)
	$MarginContainer/VBoxContainer/TriggerContainer/HBoxContainer/TextEdit.text = ""
