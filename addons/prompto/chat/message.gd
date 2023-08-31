@tool
extends Resource
class_name MessageEntry

enum MessageRole {ASSISTANT, FUNCTION, USER}

var content: String
var role: MessageRole

func _init(role: MessageRole, content: String):
	self.role = role
	self.content = content

