@tool
extends TextEdit 

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _gui_input(event):
	if self.has_focus() and event is InputEventKey and event.pressed:
		
		if Input.is_key_pressed(KEY_SHIFT) and event.keycode == KEY_ENTER:
			self.insert_text_at_caret("\n")
			return
		
		if event.keycode == KEY_ENTER:
			var prompto_manager = get_node("/root/PromptoManager")
			var prompt = self.text.strip_edges()
			print("Sending request to server...")
			
			var rq_message_entry = MessageEntry.new("", "", MessageEntry.MessageRole.USER, prompt)
			var request_message_box = await self.owner.add_message(rq_message_entry)
			self.text = ""
			self.accept_event()
			
			var response = await prompto_manager.create_chat(prompt)
			print("Server respondet")
			
			# Check if response was successful. If it wasn't, we display the Warning next to the sent message
			if (response.status != 200):
				request_message_box.display_warning("Error: Server responded with status code \"" +
					str(response.status) +"\". See Output for more details")
				printerr("Prompto-Chat Error! Got ressponse with status " + 
					str(response.status) + " and body: " + str(response.body))
				return
			
			var body = response.body
			
			var res_msg = body['messages'][-1]
			var response_message = MessageEntry.new(res_msg['id'], body['history_id'], MessageEntry.MessageRole.ASSISTANT, res_msg['content'])
			self.owner.add_message(response_message)
			
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
