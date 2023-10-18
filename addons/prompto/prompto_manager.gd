@tool
extends Node

var session_store: SessionStore:
	get:
		return session_store
	set(new_store):
		session_store = new_store
		
var prompto_client: PromptoClient:
	get:
		return prompto_client
		
const SAVE_DIR = 'user://'
const SAVEFILE_PATH = SAVE_DIR + 'prompto_session.dat'
var SAVEFILE_SECRET = OS.get_unique_id()
var settings: EditorSettings

# Called when the node enters the scene tree for the first time.
func _enter_tree():
	self.prompto_client = PromptoClient.new()
	add_child(self.prompto_client)
	self.session_store = await self._recover_session_store_or_new()
	
	self.prompto_client.session_store = self.session_store
	
func _recover_session_store_or_new() -> SessionStore:
	assert(self.prompto_client)
	
	var loaded_session = self._load_session()
	if loaded_session:
		if loaded_session.is_valid():
			return loaded_session
		
		print("Session expired.")
	print("Session could not be recovered.")
	
	return SessionStore.new()
		
func _save_session() -> void: # TODO return error if failed
	var dir = DirAccess.open(".")
	if !dir.dir_exists(SAVE_DIR):
		dir.make_dir_recursive(SAVE_DIR)
	
	var file = FileAccess.open_encrypted_with_pass(SAVEFILE_PATH, FileAccess.WRITE, SAVEFILE_SECRET)
	print(file.get_open_error())
	if file:
		file.store_var(self.session_store.to_json())
		file.close()
		print("Session saved to disk.")

func _load_session() -> SessionStore:
	if FileAccess.file_exists(SAVEFILE_PATH):
		var file = FileAccess.open_encrypted_with_pass(SAVEFILE_PATH, FileAccess.READ, SAVEFILE_SECRET)
		if file:
			var loaded_session_dict = JSON.parse_string(file.get_var())
			var session_store: SessionStore = SessionStore.from_json(loaded_session_dict)
			if session_store.is_valid():
				return session_store

	return null

func _delete_stored_session() -> void:
	if FileAccess.file_exists(SAVEFILE_PATH):
		DirAccess.remove_absolute(SAVEFILE_PATH)
	
func attempt_login():
	var login_handler = self._get_login_handler()
	self.prompto_client.login(login_handler)
	
	var prompto_id = await login_handler.token_received
	
	# tear down 
	login_handler.stop_if_listening()
	remove_child(login_handler)
	
	# get user_information related to prompto_id
	var session_information = await self.prompto_client.whoami(prompto_id)
	if session_information:
		self.session_store.set_session(prompto_id, session_information.username, session_information.expires) #TODO
		_save_session()

func _get_login_handler():
	if self.has_node("LoginHandler"):
		return self.get_node("LoginHandler")
	
	var login_handler = LoginHandler.new()
	login_handler.name = "LoginHandler"
	add_child(login_handler)
	login_handler.listen()
	
	return login_handler

func attempt_logout():
	assert(self.session_store.logged_in())
	await self.prompto_client.logout()
	
	self.session_store.reset()
	self._delete_stored_session()

func create_chat(message: String):
	assert(self.session_store.logged_in())
	return await self.prompto_client.create_chat(message)

func send_feedback(history_id: String, message_id: String, feedback_type: String):
	assert(self.session_store.logged_in())
	return await self.prompto_client.send_feedback(history_id, message_id, feedback_type)

func setup_editor_settings(s: EditorSettings):
	self.settings = s
	if not self.settings.has_setting("prompto/chat_margin"):
		self.settings.set("prompto/message_margin", 60)

func get_settings():
	return self.settings

func get_message_margin():
	return self.settings.get("prompto/message_margin")

	
