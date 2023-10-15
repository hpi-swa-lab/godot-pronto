@tool
extends MarginContainer

var MESSAGE_REF = preload("res://addons/prompto/chat/message.gd")

var message_entry: 
	set(value):
		message_entry = value
		%Content.text = message_entry.content
		
		match (message_entry.role):
			MessageEntry.MessageRole.ASSISTANT:
				set("theme_override_constants/margin_right", get_message_margin())
				%Content.get("theme_override_styles/normal").bg_color = get_prompto_manager().get_settings().get_setting("interface/theme/base_color").darkened(.3)
			MessageEntry.MessageRole.USER:
				set("theme_override_constants/margin_left", get_message_margin())
				%Content.get("theme_override_styles/normal").bg_color = get_prompto_manager().get_settings().get_setting("interface/theme/accent_color").darkened(.5)
			_:
				assert(false, "Unhandled message role. :-(") 

func get_prompto_manager():
	return get_node("/root/PromptoManager")

func get_message_margin():
	return get_prompto_manager().get_message_margin()

func _ready():
	get_prompto_manager().get_settings().settings_changed.connect(_on_settings_changed)

func _on_settings_changed():
	message_entry = message_entry # trigger setter

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	
