extends Area2D

enum {COOLDOWN, HEALTH}

var type
@export var amount_of_healing: float = 3
@export var duration_of_cooldown_removal: float = 5

func _ready():
	%Icon.text = "CD" if type == COOLDOWN else "+"
	self.body_entered.connect(_handle_collected)
	
func _handle_collected(other):
	if other.name.contains("Player"):
		if type == COOLDOWN:
			other.activate_cooldown_powerup(duration_of_cooldown_removal)
			self.queue_free()
		else:
			other.heal(amount_of_healing)
			self.queue_free()
