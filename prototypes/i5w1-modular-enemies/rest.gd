extends Button


# Called when the node enters the scene tree for the first time.
func _ready():
	self.pressed.connect(_emit_pressed)

func _emit_pressed():
	var vbox = G.get_parent().get_node("i5w1-modular-enemies/PanelContainer2/ScrollContainer/VBoxContainer")
	var scrollContainer = vbox.get_parent() as ScrollContainer
	var scrollBar = scrollContainer.get_v_scroll_bar()
	var regen_amount = G.at("PlayerRestStaminaRegenAmount")
	
	
	print(">> Resting and regenerating " + str(regen_amount) + " stamina")
	
	var label = Label.new()
	label.text = "🤴: Player resting and regenerating " + str(regen_amount) + " stamina"
	vbox.add_child(label)
	scrollContainer.scroll_vertical = scrollBar.max_value
	
	var stamina: HealthBar = G.get_parent().find_child("STAMINA", true, false)
	stamina.heal(regen_amount)
	G.get_parent().get_node("i5w1-modular-enemies/STATE/player_turn/player_can_attack").exit(7)
