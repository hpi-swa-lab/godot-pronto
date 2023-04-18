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
static func connect_target(from: Node, signal_name: String, to: NodePath, invoke: String, arguments: Array, undo_redo: EditorUndoRedoManager = null):
	var c = Connection.new()
	c.signal_name = signal_name
	c.to = to
	c.invoke = invoke
	c.arguments = arguments
	c._store(from, undo_redo)

## When the [param from] [Node] emits [param signal_name], execute [param expression].
## [param expression] is passed as a string and parsed by the [Connection] instance.
## Optionally pass an [EditorUndoRedoManager] to make this action undoable.
static func connect_expr(from: Node, signal_name: String, expression: String, undo_redo: EditorUndoRedoManager = null):
	var c = Connection.new()
	c.signal_name = signal_name
	c.expression = expression
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
	return not is_expression()

## Remove this connection from [param node].
func delete(from: Node):
	_ensure_connections(from).erase(self)

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

func _append_connection(from: Node):_ensure_connections(from).append(self)
func _remove_connection(from: Node): _ensure_connections(from).erase(self)

func _ensure_connections(from: Node):
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
	
	var s = signal_arguments
	match signal_arguments.size():
		0: from.connect(signal_name, func (): _trigger(from, s, []))
		1: from.connect(signal_name, func (arg1): _trigger(from, s, [arg1]))
		2: from.connect(signal_name, func (arg1, arg2): _trigger(from, s, [arg1, arg2]))
		3: from.connect(signal_name, func (arg1, arg2, arg3): _trigger(from, s, [arg1, arg2, arg3]))
		4: from.connect(signal_name, func (arg1, arg2, arg3, arg4): _trigger(from, s, [arg1, arg2, arg3, arg4]))

func _trigger(from: Object, argument_names: Array, argument_values: Array):
	var names = argument_names.duplicate()
	var values = argument_values.duplicate()
	names.append("from")
	values.append(from)
	if to:
		var target = from.get_node(to)
		names.append("to")
		values.append(target)
		if should_trigger(names, values):
			target.callv(invoke, arguments.map(func (arg): return ConnectionsList.eval(arg, names, values)))
	else:
		if should_trigger(names, values):
			ConnectionsList.eval(expression, names, values, false)

func should_trigger(names, values):
	return only_if == "true" or only_if == "" or ConnectionsList.eval(only_if, names, values)
