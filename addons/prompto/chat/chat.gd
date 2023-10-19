@tool
extends MarginContainer

const MESSAGE_ENTRY = preload("res://addons/prompto/chat/message.gd")
const MessageBox = preload("res://addons/prompto/chat/MessageBox.tscn")

# Called when the node enters the scene tree for the first time.
func get_messages():
	return %MessageContainer.get_children()

func add_message(message: MessageEntry):
	%PromptoLabel.hide()
	var message_box = MessageBox.instantiate()
	%MessageContainer.add_child(message_box)
	message_box.message_entry = message

	# Scroll to end
	await get_tree().process_frame
	%ScrollableMessageContainer.scroll_vertical = %ScrollableMessageContainer.get_v_scroll_bar().max_value
	return message_box

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func reset():
	%PromptoLabel.show()
	
	for n in %MessageContainer.get_children():
		%MessageContainer.remove_child(n)
		n.queue_free()


