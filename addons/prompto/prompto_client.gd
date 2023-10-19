@tool
extends Node
class_name PromptoClient

var session_store: SessionStore:
	get:
		return session_store
	set(new_store):
		session_store = new_store

const DOMAIN = preload("res://addons/prompto/config.gd").BACKEND_DOMAIN
const BACKEND_API = preload("res://addons/prompto/config.gd").BACKEND_API

func _prepare_request(
	endpoint: String,
	http_method: HTTPClient.Method,
	body: Dictionary = {},
	prompto_id: String = self.session_store.prompto_id
	) -> Dictionary:
	var http_request = HTTPRequest.new()
	add_child(http_request)

	var headers = PackedStringArray([
		"Cookie: prompto_id=%s; domain=%s" % [prompto_id, DOMAIN],
		"User-Agent: Godot %s" %Engine.get_version_info(),
		"Content-Type: application/json",
	])
		
	var error = http_request.request(endpoint, headers, http_method, JSON.stringify(body))

	if error != OK:
		push_error("An error occurred in the HTTP request with ERR Code: %s" % error)
	
	var response = await http_request.request_completed
	remove_child(http_request)
	# result, status code, response headers, and body are now in indices 0, 1, 2, and 3 of response
	print("RESPONSE STATUS: ", response[1])
	print("RESPONSE PLAIN: ", response[3].get_string_from_utf8())
	if (response[3]):
		return {
			"status": response[1],
			"body": JSON.parse_string(response[3].get_string_from_utf8())
		}
	return {
		"status": response[1]
	}
	
func login(login_handler: LoginHandler):
	assert(login_handler.is_listening(), "Login Handler (TCP Server) is not listening.")
	
	var authentication_state = "my_random_auth_state"
	OS.shell_open(BACKEND_API.LOGIN_URL + "?state=" + authentication_state)

func whoami(prompto_id: String) -> Dictionary:	
	var response = await _prepare_request(BACKEND_API.WHOAMI_URL, HTTPClient.METHOD_GET, {}, prompto_id)
	return response
	
func logout() -> Dictionary:
	assert(self.session_store.logged_in())
	
	var response = await _prepare_request(BACKEND_API.LOGOUT_URL, HTTPClient.METHOD_POST)
	return response

func create_chat(text):
	assert(self.session_store.logged_in())
	
	var response = await _prepare_request(BACKEND_API.CREATE_CHAT_URL, HTTPClient.METHOD_POST, {"message": text})
	return response

func continue_chat(history_id, text):
	assert(self.session_store.logged_in())
	
	var response = await _prepare_request(BACKEND_API.CREATE_CHAT_URL, HTTPClient.METHOD_POST, {"message": text})
	return response

## Sends feedback to the backend
func send_feedback(history_id: String, message_id: String, feedback_type: String):
	assert(self.session_store.logged_in())
	
	var request_body = {
		"history_id": history_id,
		"message_id": message_id,
		"feedback_type": feedback_type
	}
	
	var response = await _prepare_request(BACKEND_API.FEEDBACK_URL, HTTPClient.METHOD_POST, request_body)
	return response
