@tool
extends Node
class_name LanguageClient

signal on_notification(data: Dictionary)
signal on_response(data: Dictionary)

func _ready():
	socket = StreamPeerTCP.new()
	socket.connect_to_host('127.0.0.1', 6005)
	socket.poll()
	socket.set_no_delay(true)
	
	send_request('initialize', {
		'processId': null,
		'clientInfo': {'name': 'pronto'},
		'rootUri': 'file://' + ProjectSettings.globalize_path("res://"),
		'capabilities': {
			'textDocument': {'hover': {}, 'synchronization': {'dynamicRegistration': true}},
			'workspace': {'applyEdit': true, 'workspaceEdit': {'documentChanges': true}},
		},
	}, func (r): pass)

func script_path(script: Script):
	return "file://" + ProjectSettings.globalize_path(script.resource_path)

func _exit_tree():
	socket.disconnect_from_host()

func _process(delta):
	if Engine.is_editor_hint():
		return
	socket.poll()
	var m = receive_message()
	if m != null:
		if "id" in m:
			_waiting_handlers[int(m["id"])].call(m["result"])
			_waiting_handlers.erase(int(m["id"]))
		else:
			on_notification.emit(m)

func completion(script: Script, line: int, character: int, cb: Callable):
	send_request('textDocument/completion', {
		'textDocument': {'uri': script_path(script)}, 'position': {'line': line, 'character': character}
	}, cb)

var _waiting_handlers = {}
var _document_versions = {}

func did_change(script: Script):
	if not script.resource_path in _document_versions:
		_document_versions[script.resource_path] = 1
	else:
		_document_versions[script.resource_path] += 1
	send_notification("textDocument/didChange", {
		"textDocument": {"uri": script_path(script), "version": _document_versions[script.resource_path]},
		"contentChanges": {"text": script.source_code}
	})

func did_open(script: Script):
	send_notification("textDocument/didOpen", {'textDocument': {
		'uri': script_path(script),
		'text': script.source_code
	}})

func send_notification(notification: String, params: Dictionary):
	send({'jsonrpc': '2.0', 'method': notification, 'params': params})

func send_request(request: String, params: Dictionary, cb: Callable):
	var my_id = current_id
	current_id = current_id + 1
	_waiting_handlers[my_id] = cb
	send({'jsonrpc': '2.0', 'id': my_id, 'method': request, 'params': params})

func send(obj: Dictionary):
	print("> " + str(obj))
	var data = JSON.stringify(obj).to_utf8_buffer()
	socket.put_data('Content-Length: {0}\r\n\r\n'.format([data.size()]).to_utf8_buffer())
	socket.put_data(data)

var current_id = 1
var socket: StreamPeerTCP
var buffer = ""

func receive_message():
	var available = socket.get_available_bytes()
	buffer += socket.get_string(available)
	
	var header_end = buffer.find("\r\n\r\n")
	if header_end >= 0:
		var headers = {}
		for pair in Array(buffer.substr(0, header_end).split("\r\n")).map(func (header): return header.split(': ')):
			assert(pair.size() == 2)
			headers[pair[0].to_lower()] = pair[1]
		assert("content-length" in headers)
		
		var json_length = int(headers["content-length"])
		var total_length = header_end + 4 + json_length
		if buffer.length() < total_length:
			return null
		var json = buffer.substr(header_end + 4, json_length)
		var data = JSON.parse_string(json)
		buffer = buffer.substr(total_length)
		return data
	else:
		return null
