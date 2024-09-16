@tool
extends TextEdit 

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _gui_input(event):
	if self.has_focus() and event is InputEventKey and event.pressed:
		
		# If the user presses shift + enter, we insert a new line
		if Input.is_key_pressed(KEY_SHIFT) and event.keycode == KEY_ENTER:
			self.insert_text_at_caret("\n")
			return
		
		# If the user presses enter, we send the message to the server
		if event.keycode == KEY_ENTER:
			var prompto_manager = get_node("/root/PromptoManager")
			var prompt = self.text.strip_edges()
			print("PROMPTO: Sending request to server...")
			
			# We add the sent message to the chat window directly
			var rq_message_entry = MessageEntry.new("", "", MessageEntry.MessageRole.USER, prompt)
			var request_message_box = await self.owner.add_message(rq_message_entry)
			self.text = ""
			self.accept_event()
			
			var response = await prompto_manager.create_chat(prompt)
			print("PROMPTO: Server respondet")
			
			# Hide the loading animation after the response was received
			request_message_box.hide_loading()
			
			# Check if response was successful. If it wasn't, we display the Warning next to the sent message
			if (response.status != 200):
				request_message_box.display_warning("Error: Server responded with status code \"" +
					str(response.status) +"\". See Output for more details")
				printerr("PROMPTO: Chat Error! Got ressponse with status " + 
					str(response.status) + " and body: " + str(response.body))
				return
			
			# If the response was successful, we add the response to the chat window
			var body = response.body
			var res_msg = body['messages'][-1]
			var response_message = MessageEntry.new(res_msg['id'], body['history_id'], MessageEntry.MessageRole.ASSISTANT, res_msg['content'])
			self.owner.add_message(response_message)
