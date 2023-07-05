extends Button


func _ready():
	self.pressed.connect(_emit_pressed)

func _emit_pressed():
	_do_player_attack("heavy")
	G.get_parent().get_node("i5w1-modular-enemies/STATE/player_turn/player_can_attack").exit(7)
	
func _do_player_attack(type: String):
	var rng = RandomNumberGenerator.new()
	var stamina: HealthBar = G.get_parent().find_child("STAMINA", true, false)
	var base_damage = G.at("PlayerBaseDamage")
	var hit_chance = G.at("PlayerChanceToHit")
	
	var vbox = G.get_parent().get_node("i5w1-modular-enemies/PanelContainer2/ScrollContainer/VBoxContainer")
	var scrollContainer = vbox.get_parent() as ScrollContainer
	var scrollBar = scrollContainer.get_v_scroll_bar()
	
	if rng.randi_range(0, 100) < hit_chance:
		var target_hb: HealthBar = G.get_parent().find_child(G.at("Target"), true, false).find_child("HealthBar*", false, true)
		if type == "light":
			target_hb.damage(base_damage)
			stamina.damage(G.at("PlayerLightAttackStaminaCost"))
			print(">> Damaged enemy " + G.at("Target") + " for " + str(base_damage) + " points with light attack")
		elif type == "heavy":
			var damage = base_damage * G.at("PlayerHeavyAttackDamageMultiplier")
			target_hb.damage(damage)
			stamina.damage(G.at("PlayerHeavyAttackStaminaCost"))
			print(">> Damaged enemy " + G.at("Target") + " for " + str(damage) + " points with heavy attack")
			
			var label = Label.new()
			label.text = "🤴: Damaged enemy " + G.at("Target") + " for " + str(damage) + " points with heavy attack"
			vbox.add_child(label)
			scrollContainer.scroll_vertical = scrollBar.max_value
		else:
			push_error("INVALID ATTACK TYPE")	
	else:
		var label = Label.new()
		label.text = "🤴: Player missed their attack"
		vbox.add_child(label)
		scrollContainer.scroll_vertical = scrollBar.max_value
		
		print(">> Player missed their attack")
		return
