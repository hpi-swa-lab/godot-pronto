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
static func connect_target(from: Node, signal_name: String, to: NodePath, invoke: String, arguments: Array[String]):
	var c = Connection.new()
	c.signal_name = signal_name
	c.to = to
	c.invoke = invoke
	c.arguments = arguments
	c._store(from)

## When the [param from] [Node] emits [param signal_name], execute [param expression].
## [param expression] is passed as a string and parsed by the [Connection] instance.
static func connect_expr(from: Node, signal_name: String, expression: String):
	var c = Connection.new()
	c.signal_name = signal_name
	c.expression = expression
	c._store(from)

## Returns list of all connections from [param node]
static func get_connections(node: Node) -> Array[Connection]:
	if not node.has_meta("pronto_connections"):
		return []
	else:
		return node.get_meta("pronto_connections")

## The signal name of the node that this connection is added on to connect to.
@export var signal_name: String = ""
## (Optional) The path to the node that this connection emits to.
@export var to: NodePath = ^""
## (Optional) The method to invoke on [member to].
@export var invoke: String = ""
## (Optional) The arguments to pass to method [member invoke].
@export var arguments: Array[String] = []
## (Optional) Only used when neither [member to], [member invoke], or [member arguments] is not set.
## A string describing the [Expression] that is to be run when [member signal_name] triggers.
@export var expression: String = ""

## Return whether this connection will execute an expression.
func is_expression() -> bool:
	return expression != ""

## Return whether this connection will invoke a method on a target.
func is_target() -> bool:
	return not is_expression()

## Remove this connection from [param node].
func delete(from: Node):
	_ensure_connections(from).erase(self)

var _from: Node = null
var _arguments: Array
var _expression: Expression
var _installed := false

func _store(from: Node):
	var connections = _ensure_connections(from)
	if connections.any(func (c: Connection): return c == self): return
	connections.append(self)

func _ensure_connections(from: Node):
	var connections: Array[Connection]
	if from.has_meta("pronto_connections"):
		connections = from.get_meta("pronto_connections")
	else:
		connections = []
		from.set_meta("pronto_connections", connections)
	return connections

func _install_in_game(from: Node):
	if Engine.is_editor_hint():
		return
	
	if _from:
		if _from != from:
			push_error("Attempting to re-bind connection")
		return
	_from = from
	
	var signal_arguments: Array = (from.get_signal_list()
		.filter(func (s): return s["name"] == signal_name)
		.map(func (s): return s["args"].map(func (a): return a["name"])))[0]
	
	if arguments:
		_arguments = arguments.map(func (expr: String):
			var e := Expression.new()
			e.parse(expr, signal_arguments)
			return e)
	
	if expression:
		_expression = Expression.new()
		_expression.parse(expression, signal_arguments)
	
	from.connect(signal_name, Callable(self, "_trigger" + str(signal_arguments.size())))

func _trigger(arguments: Array):
	if to:
		var target = _from.get_node(to)
		target.callv(invoke, _arguments.map(func (arg: Expression): return arg.execute(arguments, target)))
	else:
		_expression.execute(arguments, _from)

func _trigger0():
	_trigger([])
func _trigger1(arg1):
	_trigger([arg1])
func _trigger2(arg1, arg2):
	_trigger([arg1, arg2])
func _trigger3(arg1, arg2, arg3):
	_trigger([arg1, arg2, arg3])
func _trigger4(arg1, arg2, arg3, arg4):
	_trigger([arg1, arg2, arg3, arg4])
