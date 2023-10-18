@tool
extends MarginContainer

var MESSAGE_REF = preload("res://addons/prompto/chat/message.gd")

var message_entry: MessageEntry: 
	set(value):
		message_entry = value
		%Content.text = message_entry.content
		
		match (message_entry.role):
			MessageEntry.MessageRole.ASSISTANT:
				set("theme_override_constants/margin_right", get_message_margin())
				%Content.get("theme_override_styles/normal").bg_color = get_prompto_manager().get_settings().get_setting("interface/theme/base_color").darkened(.3)
				# Add tooltip to response
				%Content.tooltip_text = "This is the response generated by Prompto"
			MessageEntry.MessageRole.USER:
				set("theme_override_constants/margin_left", get_message_margin())
				%Content.get("theme_override_styles/normal").bg_color = get_prompto_manager().get_settings().get_setting("interface/theme/accent_color").darkened(.5)
				# Hide Feedback buttons for own messages
				self.find_child("FeedbackButtons").visible = false
				# Add tooltip to your own message
				%Content.tooltip_text = "This is your message"
			_:
				assert(false, "Unhandled message role. :-(") 

func get_prompto_manager():
	return get_node("/root/PromptoManager")

func get_message_margin():
	return get_prompto_manager().get_message_margin()

func _ready():
	get_prompto_manager().get_settings().settings_changed.connect(_on_settings_changed)
	%LikeButton.button_down.connect(_like_message)
	%DislikeButton.button_down.connect(_dislike_message)

func _on_settings_changed():
	message_entry = message_entry # trigger setter

# Give positive feedback for the given response
func _like_message():
	_send_feedback("positive")

# Give negative feedback for the given response
func _dislike_message():
	_send_feedback("negative")

func _send_feedback(feedback_type: String):
	var prompto_manager = get_node("/root/PromptoManager")
	var history_id = message_entry.history_id
	var uuid = message_entry.uuid
	
	var response = await prompto_manager.send_feedback(history_id, uuid, feedback_type)
	print("Feedback Response: ", response)
#	TODO: SEND FEEDBACK: var response = await prompto_manager

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	
