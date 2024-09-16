@tool
extends Resource
class_name SessionStore

var prompto_id: String:
	get:
		return prompto_id

var username: String:
	get:
		return username
		
var expires: int:
	get:
		return expires

func set_session(prompto_id: String, username: String, expires: int):
	self.prompto_id = prompto_id
	self.username = username
	self.expires = expires
	
	self.changed.emit(self.logged_in())
			
func logged_in() -> bool:
	if self.prompto_id && self.username && is_valid():
		return true
	return false
	
func is_valid():
	var current_time = Time.get_unix_time_from_system()
	return current_time < self.expires

func to_json() -> String:
	return JSON.stringify({
		"prompto_id": self.prompto_id,
		"username": self.username,
		"expires": self.expires
	})
	
func reset():
	self.prompto_id = ""
	self.username = ""
	self.expires = 0
	
	self.changed.emit(false)
	
static func from_json(dict: Dictionary) -> SessionStore:
	var session_store = SessionStore.new()
	session_store.set_session(dict["prompto_id"], dict["username"], dict["expires"]) 
	return session_store
