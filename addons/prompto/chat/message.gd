@tool
extends Resource
class_name MessageEntry

enum MessageRole {ASSISTANT, FUNCTION, USER}


var uuid: String
var content: String
var role: MessageRole

func _init(uuid: String, role: MessageRole, content: String):
	self.uuid = uuid
	self.role = role
	self.content = content
