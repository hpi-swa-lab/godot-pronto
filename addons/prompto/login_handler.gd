@tool
extends Node
class_name LoginHandler

var PORT := 39714
var BINDING := "127.0.0.1"


var redirect_server = TCPServer.new()

signal token_received(token: String)

# Called when the node enters the scene tree for the first time.
func _ready():
	set_process(false)
	
func is_listening():
	return self.redirect_server.is_listening()
	
func stop_if_listening():
	if self.redirect_server.is_listening():
		redirect_server.stop()

func listen():
	set_process(true)
	redirect_server.listen(PORT, BINDING)
	
func _process(_delta):
	if redirect_server.is_connection_available():
		var connection = redirect_server.take_connection()
		var request = connection.get_string(connection.get_available_bytes())
		if request:
			set_process(false)
			
			var request_params_str = request.split("\n")
			var query = request_params_str[0]
			
			# TODO Quick and dirty parsing
			assert('?' in query)
			var prompto_id = query.split('=')[1].split(' ')[0]
			print(prompto_id)
			# TODO Headers are not used.
			# var headers_str = request_params_str.slice(1, request_params_str.size() - 1)
			# var headers = {}
			# for header_str in headers_str:
			#	var split = header_str.split(": ")
			#	
			#	if (split.size() == 2):
			#		var key = split[0]
			#		var value = split[1]
			#		headers[key] = value
			
			# Set new session id
			token_received.emit(prompto_id)
			
			# Return success HTML Page
			connection.put_data(("HTTP/1.1 %d Temporary Redirect\r\n" % 307).to_utf8_buffer())
			connection.put_data("Location: http://prompto.overfitting.org/auth/success".to_utf8_buffer())
			redirect_server.stop()


func parse_string_to_dict(string, item_delimiter, key_value_delimiter):
	var dict = {}
	var pairs = string.strip_edges().split(item_delimiter)
	
	for pair in pairs:
		var split = pair.split(key_value_delimiter)
		if split.size() == 2:
			var key = split[0]
			var value = split[1].strip_edges()
			dict[key] = value.substr(0, value.length()) # Remove quotation marks
			
	return dict

func load_HTML(path):
	if FileAccess.file_exists(path):
		var file = FileAccess.open(path, FileAccess.READ)
		var HTML = file.get_as_text().replace("    ", "\t").insert(0, "\n")
		file.close()
		return HTML

