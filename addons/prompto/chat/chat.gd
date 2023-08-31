@tool
extends MarginContainer

const MESSAGE_ENTRY = preload("res://addons/prompto/chat/message.gd")
const MessageBox = preload("res://addons/prompto/chat/MessageBox.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	#_init_chat_history()
	pass

func add_message(message: MessageEntry):
	%PromptoLabel.hide()
	var message_box = MessageBox.instantiate()
	%MessageContainer.add_child(message_box)
	message_box.message_entry = message

	# Scroll to end
	await get_tree().process_frame
	%ScrollableMessageContainer.scroll_vertical = %ScrollableMessageContainer.get_v_scroll_bar().max_value

func _init_chat_history():
	var chat_history = [
		MessageEntry.new(MessageEntry.MessageRole.ASSISTANT, "Ignorant saw her her drawings marriage laughter. Case oh an that or away sigh do here upon. Acuteness you exquisite ourselves now end forfeited. Enquire ye without it garrets up himself. Interest our nor received followed was. Cultivated an up solicitude mr unpleasant.

Throwing consider dwelling bachelor joy her proposal laughter. Raptures returned disposed one entirely her men ham. By to admire vanity county an mutual as roused. Of an thrown am warmly merely result depart supply. Required honoured trifling eat pleasure man relation. Assurance yet bed was improving furniture man. Distrusts delighted she listening mrs extensive admitting far.
"),
		MessageEntry.new(MessageEntry.MessageRole.USER, "How can I transform x to y?"),
	]
	
	for message in chat_history:
		self.add_message(message)	
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

