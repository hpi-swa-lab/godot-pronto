extends StaticBody2D

var attacker: CharacterBody2D = null
@export var life_property: String = ""
var state: State


func _ready():
	state = get_node("State")

func game_over():
	print("game over")
	if attacker != null:
		attacker.reset_target()
	get_tree().paused = true
	
func set_attacker(node: CharacterBody2D):
	attacker = node
	attacker.target = self
	attacker.stop_moving()
	
func attacker_in_range(node: CharacterBody2D):
	if node.target == null:
		set_attacker(node)
	if node.target == self and attacker != null:
		apply_damage(attacker.damage)

func apply_damage(amount: float):
	state.put(life_property, max(0, G.at(life_property) - amount))
	if G.at(life_property) == 0:
		game_over()

