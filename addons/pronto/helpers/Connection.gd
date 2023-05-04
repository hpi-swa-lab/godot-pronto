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
static func connect_target(from: Node, signal_name: String, to: NodePath, invoke: String, arguments: Array, only_if: String, undo_redo: EditorUndoRedoManager = null):
	var c = Connection.new()
	c.signal_name = signal_name
	c.to = to
	c.invoke = invoke
	c.arguments = arguments
	c.only_if = only_if
	c._store(from, undo_redo)

## When the [param from] [Node] emits [param signal_name], execute [param expression].
## [param expression] is passed as a string and parsed by the [Connection] instance.
## Optionally pass an [EditorUndoRedoManager] to make this action undoable.
static func connect_expr(from: Node, signal_name: String, to: NodePath, expression: String, only_if: String, undo_redo: EditorUndoRedoManager = null):
	var c = Connection.new()
	c.signal_name = signal_name
	c.to = to
	c.expression = expression
	c.only_if = only_if
	c._store(from, undo_redo)

## Returns list of all connections from [param node]
static func get_connections(node: Node) -> Array:
	return node.get_meta("pronto_connections", [])

## The signal name of the node that this connection is added on to connect to.
@export var signal_name: String = ""
## (Optional) The path to the node that this connection emits to.
@export var to: NodePath = ^""
## (Optional) The method to invoke on [member to].
@export var invoke: String = ""
## (Optional) The arguments to pass to method [member invoke] as [String]s.
@export var arguments: Array = []
## Only trigger this connection if this expression given as [String] evaluates to true.
@export var only_if: String = "true"
## (Optional) Only used when neither [member to], [member invoke], or [member arguments] is not set.
## A string describing the [Expression] that is to be run when [member signal_name] triggers.
@export_multiline var expression: String = ""

## Return whether this connection will execute an expression.
func is_expression() -> bool:
	return expression != ""

## Return whether this connection will invoke a method on a target.
func is_target() -> bool:
	return not to.is_empty()

## Remove this connection from [param node].
func delete(from: Node, undo_redo: EditorUndoRedoManager = null):
	if undo_redo == null:
		_ensure_connections(from).erase(self)
	else:
		undo_redo.create_action("Delete connection")
		undo_redo.add_do_method(self, "_remove_connection", from)
		undo_redo.add_undo_method(self, "_append_connection", from)
		undo_redo.commit_action()

## Reorder the connection at the given index in its connection list to be the first.
static func reorder_to_top(from: Node, index: int, undo_redo: EditorUndoRedoManager = null, update_display = null):
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

func _store(from: Node, undo_redo: EditorUndoRedoManager = null):
	var connections = _ensure_connections(from)
	if connections.any(func (c: Connection): return c == self): return
	
	if undo_redo != null:
		undo_redo.create_action("Create connection")
		undo_redo.add_do_method(self, "_append_connection", from)
		undo_redo.add_undo_method(self, "_remove_connection", from)
		undo_redo.commit_action()
	else:
		connections.append(self)

static func _move_connection(from: Node, current: int, new: int):
	var list = _ensure_connections(from)
	var c = list.pop_at(current)
	list.insert(new, c)
func _append_connection(from: Node):_ensure_connections(from).append(self)
func _remove_connection(from: Node): _ensure_connections(from).erase(self)

static func _ensure_connections(from: Node):
	var connections: Array
	if from.has_meta("pronto_connections"):
		connections = from.get_meta("pronto_connections")
	else:
		connections = []
		from.set_meta("pronto_connections", connections)
	return connections

func _install_in_game(from: Node):
	if Engine.is_editor_hint():
		return
	
	var signal_arguments: Array = Utils.find(from.get_signal_list(), func (s): return s["name"] == signal_name)["args"].map(func (a): return a["name"])
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
		if c.signal_name != signal_name:
			continue
		var names = argument_names.duplicate()
		var values = argument_values.duplicate()
		names.append("from")
		values.append(from)
		if not c.is_expression():
			var target = from.get_node(c.to)
			names.append("to")
			values.append(target)
			if c.should_trigger(names, values, from):
				var args = c.arguments.map(func (arg): return ConnectionsList.eval(arg, names, values, true, from))
				target.callv(c.invoke, args)
				EngineDebugger.send_message("pronto:connection_activated", [c.resource_path, ",".join(args.map(func (s): return str(s)))])
		else:
			if c.is_target():
				var target = from.get_node(c.to)
				names.append("to")
				values.append(target)
			if c.should_trigger(names, values, from):
				ConnectionsList.eval(c.expression, names, values, false, from)
				EngineDebugger.send_message("pronto:connection_activated", [c.resource_path, ""])

func has_condition():
	return only_if != "true" and only_if != ""

func should_trigger(names, values, from):
	return not has_condition() or ConnectionsList.eval(only_if, names, values, true, from)

func make_unique(from: Node, undo_redo: EditorUndoRedoManager):
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

func print(flip = false, shorten = true):
	var prefix = "[?] " if has_condition() else ""
	if is_target():
		var invocation_string = "{0}({1})".format([invoke, ",".join(arguments.map(func (a): return str(a)))])
		var statements_string = expression.split('\n')[0]
		return ("{1}{2} ← {0}" if flip else "{1}{0} → {2})").format([
			signal_name,
			prefix,
			Utils.ellipsize(invocation_string if not is_expression() else statements_string, 16 if shorten else -1)
		])
	else:
		return "{2}{0} ↺ {1}".format([signal_name, Utils.ellipsize(expression.split('\n')[0], 16 if shorten else -1), prefix])
