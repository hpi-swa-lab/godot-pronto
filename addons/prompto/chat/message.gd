@tool
extends Resource
class_name MessageEntry

enum MessageRole {ASSISTANT, FUNCTION, USER}


var uuid: String
var history_id: String
var content: String
var role: MessageRole

func _init(uuid: String, history_id: String, role: MessageRole, content: String):
	self.uuid = uuid
	self.history_id = history_id
	self.role = role
	self.content = content
