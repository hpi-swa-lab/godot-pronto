extends CharacterBody2D


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
@warning_ignore("unused_parameter")
func _process(delta):
	pass


func _on_node_2d_combo_buff(activated):
	if activated:
		$HealthBarBehavior.invulnerable = true
	else:
		$HealthBarBehavior.invulnerable = false

func onHeal():
	$HealthBarBehavior.heal(5)

func onAttacked(damage):
	$HealthBarBehavior.damage(damage)
