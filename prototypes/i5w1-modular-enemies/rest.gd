extends Button


# Called when the node enters the scene tree for the first time.
func _ready():
	self.pressed.connect(_emit_pressed)

func _emit_pressed():
	var regen_amount = G.at("PlayerRestStaminaRegenAmount")
	print(">> Resting and regenerating " + str(regen_amount) + " stamina")
	var stamina: HealthBar = G.get_parent().find_child("STAMINA", true, false)
	stamina.heal(regen_amount)
	G.get_parent().get_node("i5w1-modular-enemies/STATE/player_turn/player_can_attack").exit(7)
