@tool
extends Resource
class_name Connection

## Wrapper for richer Signals.
##
## A [Connection] wraps a Godot signal to allow for richer effects to take
## place when the signal occurs. A [Connection] can exist in two forms:
## Either, it invokes a method on a target node, or it runs an arbitrary expression.
## Connections are stored in a [code]pronto_connections[/code] meta property on
## each node that they are connected from.
## [br][br]
## [b]Note[/b]: Requires [code]ConnectionsList.gd[/code] to be in the autoload list to work.

## When the [param from] [Node] emits [param signal_name], call method [param invoke] on
## [Node] [param to], passing [param arguments] to the method.
## Optionally pass an [EditorUndoRedoManager] to make this action undoable.
static func connect_target(from: Node, signal_name: String, to: NodePath, invoke: String, arguments: Array, more_references: Array, only_if: ConnectionScript, undo_redo = null):
	var c = Connection.new()
	c.signal_name = signal_name
	c.to = to
	c.invoke = invoke
	c.arguments = arguments
	c.more_references = more_references
	c.only_if = only_if
	c._store(from, undo_redo)
	return c

## When the [param from] [Node] emits [param signal_name], execute [param expression].
## [param expression] is passed as a string and parsed by the [Connection] instance.
## Optionally pass an [EditorUndoRedoManager] to make this action undoable.
static func connect_expr(from: Node, signal_name: String, to: NodePath, expression: ConnectionScript, more_references: Array, only_if: Resource, undo_redo = null):
	var c = Connection.new()
	c.signal_name = signal_name
	c.to = to
	c.expression = expression
	c.more_references = more_references
	c.only_if = only_if
	c._store(from, undo_redo)
	return c

## Returns list of all connections from [param node]
static func get_connections(node: Node) -> Array:
	return node.get_meta("pronto_connections", [])

## The signal name of the node that this connection is added on to connect to.
@export var signal_name: String = ""
## (Optional) The path to the node that this connection emits to.
@export var to: NodePath = ^""
## (Optional) Paths to further nodes that the connection code may refer to.
@export var more_references = []:
	get:
		if more_references == null:
			# migrate old instances
			more_references = []
		return more_references
## (Optional) The method to invoke on [member to].
@export var invoke: String
## (Optional) The arguments to pass to method [member invoke] as [ConnectionScript]s.
@export var arguments: Array = []
## Only trigger this connection if this expression given as [String] evaluates to true.
@export var only_if: ConnectionScript
## (Optional) Only used when neither [member to], [member invoke], or [member arguments] is not set.
## A string describing the [Expression] that is to be run when [member signal_name] triggers.
@export var expression: ConnectionScript
## Run action of this connection in the next frame after it was triggered
@export var deferred = false
## Enable this connection for quick debugging
@export var enabled = true :
	get:
		if enabled == null:
			enabled = true
		return enabled
	set(new_value):
		enabled = new_value

## Return whether this connection will execute an expression.
func is_expression() -> bool:
	return expression != null

## Return whether this connection will invoke a method on a target.
func is_target() -> bool:
	return not to.is_empty()

## Remove this connection from [param node].
func delete(from: Node, undo_redo = null):
	if undo_redo == null:
		_ensure_connections(from).erase(self)
	else:
		undo_redo.create_action("Delete connection")
		undo_redo.add_do_method(self, "_remove_connection", from)
		undo_redo.add_undo_method(self, "_append_connection", from)
		undo_redo.commit_action()

## Toggle this node on and off
func toggle_enabled(undo_redo = null):
	if undo_redo == null:
		enabled = !enabled
		return 
	undo_redo.create_action("%s connection" % ("Disable" if enabled else "Enable"))
	undo_redo.add_do_method(self, "set", "enabled", !enabled)
	undo_redo.add_do_method(ConnectionsList, "emit_connections_changed")
	undo_redo.add_undo_method(self, "set", "enabled", enabled)
	undo_redo.add_undo_method(ConnectionsList, "emit_connections_changed")
	undo_redo.commit_action()

## Reorder the connection at the given index in its connection list to be the first.
static func reorder_to_top(from: Node, index: int, undo_redo = null, update_display = null):
	if undo_redo != null:
		undo_redo.create_action("Move connection first")
		undo_redo.add_do_method(Connection, "_move_connection", from, index, 0)
		undo_redo.add_undo_method(Connection, "_move_connection", from, 0, index)
		if update_display:
			undo_redo.add_do_method(update_display.get_object(), update_display.get_method())
			undo_redo.add_undo_method(update_display.get_object(), update_display.get_method())
		undo_redo.commit_action()
	else:
		_move_connection(from, index, 0)
		ConnectionsList.emit_connections_changed()

func _store(from: Node, undo_redo = null):
	var connections = _ensure_connections(from)
	if connections.any(func (c: Connection): return c == self): return
	
	if undo_redo != null:
		undo_redo.create_action("Create connection")
		undo_redo.add_do_method(self, "_append_connection", from)
		undo_redo.add_undo_method(self, "_remove_connection", from)
		undo_redo.commit_action()
	else:
		connections.append(self)
		ConnectionsList.emit_connections_changed()

static func _move_connection(from: Node, current: int, new: int):
	var list = _ensure_connections(from)
	var c = list.pop_at(current)
	list.insert(new, c)
	ConnectionsList.emit_connections_changed()
func _append_connection(from: Node):
	_ensure_connections(from).append(self)
	ConnectionsList.emit_connections_changed()
func _remove_connection(from: Node):
	_ensure_connections(from).erase(self)
	ConnectionsList.emit_connections_changed()

static func _ensure_connections(from: Node):
	var connections: Array
	if from.has_meta("pronto_connections"):
		connections = from.get_meta("pronto_connections")
	else:
		connections = []
		from.set_meta("pronto_connections", connections)
	return connections

static func _signal_args(from: Node, name: String) -> Array:
	if name == "":
		return []
	return Utils.find(from.get_signal_list(), func (s): return s["name"] == name)["args"].map(func (a): return a["name"])

func _install_in_game(from: Node):
	if Engine.is_editor_hint():
		return
	
	var signal_arguments: Array = _signal_args(from, signal_name)
	if not from.get_signal_connection_list(signal_name).any(func (dict): return dict["callable"].get_method().begins_with("_pronto_dispatch_connections")):
		var name = "_pronto_dispatch_connections" + str(signal_arguments.size())
		from.connect(signal_name, Callable(self, name).bind(from, signal_name, signal_arguments))

func _pronto_dispatch_connections0(from: Node, signal_name: String, signal_arguments):
	_trigger(from, signal_name, signal_arguments, [])
func _pronto_dispatch_connections1(arg1, from: Node, signal_name: String, signal_arguments):
	_trigger(from, signal_name, signal_arguments, [arg1])
func _pronto_dispatch_connections2(arg1, arg2, from: Node, signal_name: String, signal_arguments):
	_trigger(from, signal_name, signal_arguments, [arg1, arg2])
func _pronto_dispatch_connections3(arg1, arg2, arg3, from: Node, signal_name: String, signal_arguments):
	_trigger(from, signal_name, signal_arguments, [arg1, arg2, arg3])
func _pronto_dispatch_connections4(arg1, arg2, arg3, arg4, from: Node, signal_name: String, signal_arguments):
	_trigger(from, signal_name, signal_arguments, [arg1, arg2, arg3, arg4])
func _pronto_dispatch_connections5(arg1, arg2, arg3, arg4, arg5, from: Node, signal_name: String, signal_arguments):
	_trigger(from, signal_name, signal_arguments, [arg1, arg2, arg3, arg4, arg5])

func _trigger(from: Object, signal_name: String, argument_names: Array, argument_values: Array):
	for c in Connection.get_connections(from):
		if !c.enabled or c.signal_name != signal_name:
			continue
		
		var names = argument_names.duplicate()
		var values = argument_values.duplicate()
		names.append("from")
		values.append(from)
		var target
		if not c.is_expression() or c.is_target():
			target = from.get_node(c.to)
			names.append("to")
			values.append(target)
		
		if not c.should_trigger(names, values, from):
			continue
		
		for i in len(self.more_references):
			var ref_path = self.more_references[i]
			var ref_node = from.get_node(ref_path)
			names.append("ref" + str(i))
			values.append(ref_node)
		
		var args_string
		if deferred: await ConnectionsList.get_tree().process_frame
		if not c.is_expression():
			var args = c.arguments.map(func (arg): return c._run_script(from, arg, values))
			if target is SceneRootBehavior:
				if c.invoke.begins_with("apply"):
					# add "from" to all "apply.*" functions, so that they can be
					# added to the context of the lambda functions.
					args.append(from)
			if target is CodeBehavior:
				target.call(c.invoke, args)
			else:
				target.callv(c.invoke, args)
			args_string = ",".join(args.map(func (s): return str(s)))
		else:
			c._run_script(from, c.expression, values)
			args_string = ""
		
		if EngineDebugger.is_active(): EngineDebugger.send_message("pronto:connection_activated", [c.resource_path, args_string])

func has_condition():
	return only_if.source_code != "true"

func should_trigger(names, values, from):
	return not has_condition() or _run_script(from, only_if, values)

func make_unique(from: Node, undo_redo):
	var old = _ensure_connections(from)
	var new = old.duplicate()
	var new_connection = duplicate(true)
	new[new.find(self)] = new_connection
	
	# FIXME does not work for some reason :(
	# undo_redo.create_action("Make connection unique")
	# undo_redo.add_do_method(from, "set_meta", "pronto_connections", new)
	# undo_redo.add_undo_method(from, "set_meta", "pronto_connections", old)
	# undo_redo.commit_action()
	
	from.set_meta("pronto_connections", new)
	assert(_ensure_connections(from) == new)
	
	return new_connection

func _run_script(from: Node, s: ConnectionScript, arguments: Array):
	return s.run(arguments, from)

func is_valid(from: Node):
	return not is_target() or from.get_node_or_null(to) != null

func print(flip = false, shorten = true, single_line = false):
	var prefix = "[?] " if has_condition() else ""
	if is_target():
		var invocation_string = "{0}({1})".format([invoke, ",".join(arguments.map(func (a): return a.source_code))])
		var statements_string = expression.source_code.split('\n')[0] if is_expression() else ""
		return ("{1}{2} ← {0}" if flip else "{1}{0} → {2}").format([
			signal_name,
			prefix,
			Utils.ellipsize(invocation_string if not is_expression() else statements_string, 16 if shorten else -1)
		]).replace("\n" if single_line else "", "")
	else:
		assert(is_expression())
		return "{2}{0} ↺ {1}".format([signal_name, Utils.ellipsize(expression.source_code.split('\n')[0], 16 if shorten else -1), prefix]).replace("\n" if single_line else "", "")

## Iterate over connections and check whether the target still exists for them.
## If not, remove the connection.
static func garbage_collect(from: Node):
	# FIXME is there a save way to make this undoable? If we just commit another action,
	# undoing will first restore the invalid connection and we have to hope the user
	# proceeds to also restore the target, but since gc is called from _process, this won't
	# happen quickly enough.
	var did_change = false
	for connection in get_connections(from).duplicate():
		if not connection.is_valid(from):
			connection.delete(from)
			did_change = true
	if did_change:
		ConnectionsList.emit_connections_changed()
