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
			
			var response = await prompto_manager.create_chat(prompt)
			print("Response from Server: ", response)
			
			# Check if response was successful
			if (response.status != 200):
				print("Error: Invalid response from server with status code " + str(response.status))
				return
			
			var body = response.body
			
			var rq_message = body['messages'][-2]
			var rq_message_entry = MessageEntry.new(rq_message['id'], body['history_id'], MessageEntry.MessageRole.USER, rq_message['content'])
			self.owner.add_message(rq_message_entry)
			
			var res_msg = body['messages'][-1]
			var response_message = MessageEntry.new(res_msg['id'], body['history_id'], MessageEntry.MessageRole.ASSISTANT, res_msg['content'])
			self.owner.add_message(response_message)
			
			self.text = ""
			self.accept_event()
			
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
